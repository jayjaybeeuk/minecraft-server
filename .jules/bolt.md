## 2025-02-12 - Explicit memory limits in itzg/minecraft-server
**Learning:** The popular `itzg/minecraft-server` Docker image defaults to only 1GB of memory. This is highly inadequate for modern Minecraft servers (like 1.21+ Paper) with plugins. It doesn't automatically adapt to container memory limits without explicit environment variables, and it doesn't automatically enable optimized Java GC tuning unless you're explicitly using 12GB+ memory.
**Action:** Always verify if `MEMORY` or `MAX_MEMORY` is explicitly configured in `docker-compose.yml`. For server types like Paper, explicitly enable Aikar's optimized GC flags with `USE_AIKAR_FLAGS=true` alongside memory allocation (like `MEMORY=4G`) to prevent GC stalls and TPS drops.

## 2026-10-30 - Backup compression bottleneck
**Learning:** Minecraft region files (.mca) and server artifacts are already inherently compressed (zlib/lz4). Running high-level compression (like PowerShell's 'Optimal' Compress-Archive) on these directories wastes massive amounts of CPU cycles for negligible disk space savings, causing backups to take significantly longer and potentially impacting server performance during the backup process.
**Action:** When writing or optimizing Minecraft backup scripts, always use the fastest compression setting ('Fastest' or 'NoCompression') rather than 'Optimal' to prioritize CPU usage and speed over redundant compression.

## 2023-11-01 - EssentialsX PlayerMoveEvent Bottleneck
**Learning:** Plugins like EssentialsX that track AFK status by default listen to `PlayerMoveEvent`. In a Minecraft server, `PlayerMoveEvent` is fired extremely frequently (dozens of times per second per moving player). Leaving `cancel-afk-on-move: true` enabled means the server spends significant main-thread CPU time just checking if players are AFK on every tiny movement, acting as a massive bottleneck as player count scales.
**Action:** When configuring or optimizing plugins that monitor activity, always disable movement-based checks (like `cancel-afk-on-move: false`) in favor of chat, command, or interaction-based checks to dramatically reduce event spam and preserve TPS.
