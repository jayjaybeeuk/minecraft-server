# CLAUDE.md

Notes for Claude Code / AI assistants working on this repo.

## What this repo is

A **Docker Compose** based Minecraft server.

## How to work safely

1) Make the smallest possible change.
2) Prefer changes that are easy to review (config + docs > magic scripts).
3) Keep everything reproducible: pinned versions, explicit defaults.

## Commands to know

```bash
docker compose config

docker compose up -d

docker compose logs -f

docker compose down
```

## Common changes

- Updating the server image tag/version
- Tweaking JVM flags (memory, GC)
- Enabling/disabling online-mode (call this out clearly)
- Adding whitelist / ops
- Adding a scheduled backup job (document where backups land)

## Do not do

- Do not commit `.env` or any tokens/keys.
- Do not delete world data volumes.
- Do not change networking/ports without mentioning it and providing rollback.
