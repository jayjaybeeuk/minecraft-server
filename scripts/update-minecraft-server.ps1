param(
    [switch]$Force,
    [switch]$SkipBackup,
    [switch]$NoPR,
    [string]$TargetVersion
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

Write-Host "=== Minecraft Server Version Check & Updater ===" -ForegroundColor Cyan

# 1. Check official Mojang version manifest
$mojangManifestUri = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
Write-Host "Checking Mojang version manifest..." -ForegroundColor Gray
$mojangManifest = Invoke-RestMethod -Uri $mojangManifestUri
$latestMojangRelease = $mojangManifest.latest.release
$latestMojangSnapshot = $mojangManifest.latest.snapshot
Write-Host "Latest Mojang release:  $latestMojangRelease" -ForegroundColor Green
Write-Host "Latest Mojang snapshot: $latestMojangSnapshot" -ForegroundColor Gray

$targetMcVersion = if ($TargetVersion) { $TargetVersion } else { $latestMojangRelease }

# 2. Check PaperMC Fill v3 API for Paper builds
Write-Host "Checking PaperMC builds for Minecraft $targetMcVersion..." -ForegroundColor Gray
$paperHeaders = @{ "User-Agent" = "minecraft-server-updater/1.0 (jayjaybeeuk)" }
try {
    $paperBuildsData = Invoke-RestMethod -Uri "https://fill.papermc.io/v3/projects/paper/versions/$targetMcVersion" -Headers $paperHeaders
    $latestPaperBuild = $paperBuildsData.builds[0]
    Write-Host "Latest Paper build for $targetMcVersion: $latestPaperBuild" -ForegroundColor Green
} catch {
    Write-Warning "Could not fetch Paper builds for $targetMcVersion: $_"
    $latestPaperBuild = "unknown"
}

# 3. Read current docker-compose.yml version
$composePath = Join-Path $repoRoot "docker-compose.yml"
$composeContent = Get-Content $composePath -Raw
$currentVersionMatch = [regex]::Match($composeContent, 'VERSION:\s*["'']?([^"''\r\n]+)["'']?')
$currentVersion = if ($currentVersionMatch.Success) { $currentVersionMatch.Groups[1].Value } else { "unknown" }
Write-Host "Current configured Minecraft VERSION: $currentVersion" -ForegroundColor Yellow

# 4. Check if Docker image needs pulling
Write-Host "Pulling latest Docker image (itzg/minecraft-server:java25)..." -ForegroundColor Gray
docker pull itzg/minecraft-server:java25

# 5. Check if update is needed
$updateNeeded = ($currentVersion -ne $targetMcVersion) -or $Force

if (-not $updateNeeded) {
    Write-Host "Minecraft server is already configured for the latest version ($currentVersion)." -ForegroundColor Green
    Write-Host "Use -Force to force the PR and Docker restart cycle." -ForegroundColor Gray
    exit 0
}

Write-Host "Preparing update to Minecraft $targetMcVersion..." -ForegroundColor Cyan

# 6. Stop container safely and create backup
$runningContainer = docker ps --filter "name=minecraft-server" -q
if ($runningContainer) {
    Write-Host "Stopping Minecraft container to release file locks..." -ForegroundColor Gray
    docker compose -f $composePath stop minecraft
}

if (-not $SkipBackup) {
    Write-Host "Creating pre-update backup of minecraft-data..." -ForegroundColor Gray
    $backupScript = Join-Path $PSScriptRoot "backup-minecraft-data.ps1"
    & powershell -ExecutionPolicy Bypass -File $backupScript
}

# 7. Update docker-compose.yml
if ($currentVersion -ne $targetMcVersion) {
    Write-Host "Updating VERSION to '$targetMcVersion' in docker-compose.yml..." -ForegroundColor Gray
    $updatedCompose = $composeContent -replace 'VERSION:\s*["''][^"'']+["'']', "VERSION: `"$targetMcVersion`""
    Set-Content -Path $composePath -Value $updatedCompose -NoNewline
}

# Validate compose configuration
Write-Host "Validating docker compose configuration..." -ForegroundColor Gray
docker compose -f $composePath config > $null
Write-Host "Compose configuration is valid." -ForegroundColor Green

# 8. Git branch, PR, and merge
if (-not $NoPR) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $branchName = "update-minecraft-$targetMcVersion-$timestamp"
    Write-Host "Creating branch $branchName..." -ForegroundColor Gray
    git checkout -b $branchName

    git add docker-compose.yml plugins.txt
    if (Test-Path (Join-Path $repoRoot "README.MD")) {
        git add README.MD
    }

    $commitMsg = "feat: update Minecraft server to $targetMcVersion"
    git commit -m $commitMsg

    Write-Host "Pushing $branchName to origin..." -ForegroundColor Gray
    git push -u origin $branchName

    Write-Host "Creating Pull Request via GitHub CLI..." -ForegroundColor Gray
    $prBody = @"
## Description
Automated update of Minecraft server to version **$targetMcVersion** (Paper build $latestPaperBuild).

### Key Changes
- Updated `VERSION` in `docker-compose.yml` to `$targetMcVersion`.
- Validated with `docker compose config`.
- World data backup created before applying changes.

### Rollback
1. Checkout previous commit on `main`.
2. Stop container: `docker compose down`.
3. Restore `minecraft-data/` from backup archive in `backups/`.
4. Run `docker compose up -d`.
"@

    $prUrl = gh pr create --title "feat: update Minecraft server to $targetMcVersion" --body $prBody --head $branchName --base main
    Write-Host "Pull Request created: $prUrl" -ForegroundColor Green

    Write-Host "Merging Pull Request into main..." -ForegroundColor Gray
    gh pr merge $branchName --merge --delete-branch
    Write-Host "Pull Request merged successfully." -ForegroundColor Green

    Write-Host "Switching to main branch and pulling latest changes..." -ForegroundColor Gray
    git checkout main
    git pull origin main
}

# 9. Restart Docker container
Write-Host "Restarting Docker container with the latest changes..." -ForegroundColor Cyan
docker compose -f $composePath down
docker compose -f $composePath up -d

Write-Host "Waiting for Minecraft server to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 10
docker compose -f $composePath logs --tail 30 minecraft

Write-Host "=== Minecraft Server update complete! ===" -ForegroundColor Green
