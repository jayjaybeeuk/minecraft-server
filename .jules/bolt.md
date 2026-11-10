## 2025-02-12 - Explicit memory limits in itzg/minecraft-server
**Learning:** The popular `itzg/minecraft-server` Docker image defaults to only 1GB of memory. This is highly inadequate for modern Minecraft servers (like 1.21+ Paper) with plugins. It doesn't automatically adapt to container memory limits without explicit environment variables, and it doesn't automatically enable optimized Java GC tuning unless you're explicitly using 12GB+ memory.
**Action:** Always verify if `MEMORY` or `MAX_MEMORY` is explicitly configured in `docker-compose.yml`. For server types like Paper, explicitly enable Aikar's optimized GC flags with `USE_AIKAR_FLAGS=true` alongside memory allocation (like `MEMORY=4G`) to prevent GC stalls and TPS drops.

## 2026-10-30 - Backup compression bottleneck
**Learning:** Minecraft region files (.mca) and server artifacts are already inherently compressed (zlib/lz4). Running high-level compression (like PowerShell's 'Optimal' Compress-Archive) on these directories wastes massive amounts of CPU cycles for negligible disk space savings, causing backups to take significantly longer and potentially impacting server performance during the backup process.
**Action:** When writing or optimizing Minecraft backup scripts, always use the fastest compression setting ('Fastest' or 'NoCompression') rather than 'Optimal' to prioritize CPU usage and speed over redundant compression.

## 2023-11-01 - EssentialsX PlayerMoveEvent Bottleneck
**Learning:** Plugins like EssentialsX that track AFK status by default listen to `PlayerMoveEvent`. In a Minecraft server, `PlayerMoveEvent` is fired extremely frequently (dozens of times per second per moving player). Leaving `cancel-afk-on-move: true` enabled means the server spends significant main-thread CPU time just checking if players are AFK on every tiny movement, acting as a massive bottleneck as player count scales.
**Action:** When configuring or optimizing plugins that monitor activity, always disable movement-based checks (like `cancel-afk-on-move: false`) in favor of chat, command, or interaction-based checks to dramatically reduce event spam and preserve TPS.

## 2023-11-05 - Squaremap Player Tracker Overhead
**Learning:** Mapping plugins like Squaremap have a `player-tracker` feature that broadcasts player positions to the web interface. By default, this is often set to an aggressive `update-interval-seconds: 1`. On a busy server, generating and broadcasting this JSON payload every single second consumes unnecessary main thread CPU cycles and network/IO overhead.
**Action:** When configuring web maps or player trackers, increase the update interval (e.g., to 3 or 5 seconds) to dramatically reduce server processing load while maintaining an acceptable UX for the web map.

## 2025-02-12 - Squaremap LeavesDecayEvent Spam
**Learning:** In mapping plugins like Squaremap, having `LeavesDecayEvent: true` in the event listeners causes immense block update spam. When a player chops down a single tree, the subsequent natural decay of the leaves triggers hundreds of individual block update events spread over a minute or more. This forces the map to constantly re-render the chunk for almost no visual change, consuming significant CPU and IO resources.
**Action:** Always ensure `LeavesDecayEvent: false` is set in the advanced event-listeners for mapping plugins to prevent massive render queue spam and wasted CPU cycles on trivial visual updates.

## 2025-02-12 - Squaremap FluidLevelChangeEvent Spam
**Learning:** In mapping plugins like Squaremap, having `FluidLevelChangeEvent: true` causes constant, massive block update spam near flowing water or lava. Liquid dynamics trigger a new event on every block change iteration. This forces the map to constantly re-render the affected chunk for minor liquid height changes, wasting significant CPU and IO resources.
**Action:** Always ensure `FluidLevelChangeEvent: false` is set in the advanced event-listeners for mapping plugins to avoid massive render queue spam and wasted server resources on minor visual liquid updates.

## 2026-10-31 - Squaremap BlockGrowEvent Spam
**Learning:** In mapping plugins like Squaremap, having `BlockGrowEvent: true` in the event listeners can cause unnecessary block update spam in agricultural or naturally overgrown areas. Crops growing incrementally generate constant events. This forces the map to constantly re-render chunks for very minor visual changes, consuming significant CPU and IO resources without providing meaningful map updates.
**Action:** Always ensure `BlockGrowEvent: false` is set in the advanced event-listeners for mapping plugins to avoid massive render queue spam and wasted server resources on minor visual crop growth updates.

## 2026-11-01 - Squaremap BlockSpreadEvent Spam
**Learning:** In mapping plugins like Squaremap, having `BlockSpreadEvent: true` in the event listeners can cause unnecessary block update spam from naturally spreading blocks like grass, mycelium, and vines. This forces the map to constantly re-render chunks for very minor visual changes, consuming significant CPU and IO resources without providing meaningful map updates.
**Action:** Always ensure `BlockSpreadEvent: false` is set in the advanced event-listeners for mapping plugins to avoid massive render queue spam and wasted server resources on minor visual block spread updates.

## 2025-02-13 - Squaremap Weather and Frost Walker Block Updates
**Learning:** In mapping plugins like Squaremap, events related to transient blocks like snow and ice cause immense chunk update spam. Natural snow accumulation (`BlockFormEvent`), ice/snow melting (`BlockFadeEvent`), and players walking with Frost Walker boots (`EntityBlockFormEvent`) trigger constant, rapid block updates that force the map to re-render the affected chunks. These changes are visually negligible on a web map but consume significant CPU and IO resources.
**Action:** Always ensure `BlockFormEvent: false`, `BlockFadeEvent: false`, and `EntityBlockFormEvent: false` are set in the advanced event-listeners for mapping plugins to avoid massive render queue spam and wasted server resources on minor visual weather/ice updates.
