param(
    [string]$SourceDir = ".\\minecraft-data",
    [string]$BackupDir = ".\\backups"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Resolve-Path (Join-Path $repoRoot $SourceDir)
$backupPath = Join-Path $repoRoot $BackupDir

if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$archiveName = "minecraft-data-$timestamp.zip"
$archivePath = Join-Path $backupPath $archiveName

# Minecraft region files (.mca) and many assets are already heavily compressed.
# Using Optimal wastes significant CPU time for almost 0 space savings.
Compress-Archive -Path (Join-Path $sourcePath "*") -DestinationPath $archivePath -CompressionLevel Fastest

Write-Output "Backup created: $archivePath"
