## 2025-02-12 - Explicit memory limits in itzg/minecraft-server
**Learning:** The popular `itzg/minecraft-server` Docker image defaults to only 1GB of memory. This is highly inadequate for modern Minecraft servers (like 1.21+ Paper) with plugins. It doesn't automatically adapt to container memory limits without explicit environment variables, and it doesn't automatically enable optimized Java GC tuning unless you're explicitly using 12GB+ memory.
**Action:** Always verify if `MEMORY` or `MAX_MEMORY` is explicitly configured in `docker-compose.yml`. For server types like Paper, explicitly enable Aikar's optimized GC flags with `USE_AIKAR_FLAGS=true` alongside memory allocation (like `MEMORY=4G`) to prevent GC stalls and TPS drops.

## 2025-02-12 - EssentialsX AFK Checks on PlayerMoveEvent
**Learning:** By default, EssentialsX checks if a player moves to cancel their AFK status (`cancel-afk-on-move: true`). Since `PlayerMoveEvent` fires extremely frequently (on every single tick a player moves), this creates unnecessary overhead and can cause TPS drops on servers with many players.
**Action:** Disable `cancel-afk-on-move` in `Essentials/config.yml` to reduce `PlayerMoveEvent` overhead. Players will still be removed from AFK status when using chat or commands.
