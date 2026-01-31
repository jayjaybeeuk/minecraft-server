# AGENTS.md

This repo runs a **dockerized Minecraft server**.

## Goals

- Keep changes **safe** and **reproducible**.
- Prefer **small PRs** with clear descriptions.
- Do not introduce secret material (tokens, private IPs, keys) into git.

## Repository conventions

- Keep server configuration in files committed to the repo where possible.
- Keep secrets in a `.env` file (ignored) or your secret store.
- Prefer explicit versions (Minecraft image tag, Java version, etc.).

## Typical workflows

### Run locally

```bash
# from repo root
cp .env.example .env  # if provided

docker compose up -d

docker compose logs -f
```

### Update the server

- Update the Docker image tag in `compose.yaml` / `docker-compose.yml`.
- Restart the container.
- Confirm the server comes back up and the world is intact.

```bash
docker compose pull
docker compose up -d
```

### Backups

- Ensure world data is persisted via a volume/bind mount.
- Prefer a simple backup script or documented manual step:

```bash
# example (adjust to match repo paths/volumes)
tar -czf backups/world-$(date +%F).tgz data/
```

## Guardrails for automation (AI or scripts)

- Before editing: list files to be changed and the plan.
- After editing: run `docker compose config` (if compose is used) to validate.
- Don’t change ports/online-mode/whitelist/op settings without calling it out in the PR.

## PR checklist

- [ ] Compose file validates (`docker compose config`)
- [ ] Change is documented (README or comments)
- [ ] No secrets committed
- [ ] Clear rollback instructions
