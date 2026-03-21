# Introduction

A simple little experiment to create a docker container for hosting a minecraft server. Evenetually we want to be able to either run this locally in:

- A Rasperry Pi and portainer
- A local synology NAS drive with containers enabled

# How to run

To run this, simply type:

`docker compose up -d`

This setup now also installs squaremap automatically on startup using the committed `plugins.txt` file.
Once the server is running, squaremap is available on port `8080`:

`http://localhost:8080`

If you are accessing the server from another machine, replace `localhost` with the Docker host's IP or hostname.

# Further changes

You can do more with this!

## Installed plugins

Plugins are pinned in `plugins.txt` and loaded by the `itzg/minecraft-server` container via `PLUGINS_FILE`.
This keeps plugin installs reproducible when the container is recreated.

squaremap is currently pinned to `1.3.12`, the official Paper build for Minecraft `1.21.11`.
The server version in `docker-compose.yml` is pinned to `1.21.11` to match that plugin build exactly.
The server also advertises the WeaponMaster overlay resource pack so players can accept it when they join.
Repo-managed plugin config files live under `plugin-config/` and are bind-mounted into the container on startup.

## squaremap first render

After the server starts and squaremap has been installed, generate the initial map with:

`docker compose exec minecraft rcon-cli squaremap fullrender world`

You can watch render progress from the server logs:

`docker compose logs -f`

squaremap data and configuration are stored in the persisted `/data` directory alongside the rest of the server data, so they survive container recreation.
In the current setup, `/data` is backed by the local `./minecraft-data` folder.

## WeaponMaster starter guide

WeaponMaster adds custom weapons, armor, tools, and progression on top of vanilla Minecraft.
For a full overview of the plugin, see the official project page:

`https://modrinth.com/plugin/weaponmasterplugin`

The official overlay resource pack is also configured on the server from:

`https://github.com/greatericontop/weaponmasterresources`

Players will be prompted to download it when joining. This is not enforced, so they can still join without it, but the custom item visuals will look much better if they accept.

### Managed plugin config

The tracked plugin config files are:

- `plugin-config/WeaponMaster/config.yml`
- `plugin-config/WeaponMaster/descent.yml`
- `plugin-config/Essentials/config.yml`
- `plugin-config/Essentials/custom_items.yml`
- `plugin-config/Essentials/kits.yml`
- `plugin-config/Essentials/motd.txt`
- `plugin-config/Essentials/tpr.yml`
- `plugin-config/Essentials/worth.yml`
- `plugin-config/LuckPerms/config.yml`
- `plugin-config/LuckPerms/contexts.json`

WeaponMaster, Essentials, and LuckPerms are mounted directly from `plugin-config/` for the selected tracked files. Runtime-heavy plugin data such as player data, warps, databases, squaremap tiles, and other generated files stay in `./minecraft-data`.

For Essentials, only the most important server-managed files are tracked in git:

- `config.yml`
- `custom_items.yml`
- `kits.yml`
- `motd.txt`
- `tpr.yml`
- `worth.yml`

## Restored admin plugins

The old admin/support plugins restored from backup are:

- `EssentialsX`
- `EssentialsXChat`
- `EssentialsXSpawn`
- `LuckPerms`
- `Vault`

Their jars are pinned in `plugins.txt`, and the selected Essentials/LuckPerms config files are tracked under `plugin-config/`.

### Good first items to unlock

These are good early-game WeaponMaster items to aim for first:

1. `Anduril`
   Recipe: `6 Feather + 1 Anvil + 1 Iron Block + 1 Iron Sword`
   Good early utility item with passive buffs while held.

2. `Throwing Knife`
   Recipe: `1 Iron Block + 1 Iron Sword + 1 Piston`
   Cheap early ranged option.

3. `Copper Sword`
   Recipe: `8 Copper Block + 1 Iron Sword`
   Useful early weapon with a stun effect.

4. `Fireball`
   Recipe: shapeless `1 TNT + 1 Fire Charge + 1 Arrow`
   Easy explosive utility item.

5. `Wither Staff`
   Recipe: `2 Blaze Rod + 1 Wither Skeleton Skull + 1 Fire Charge + 1 TNT`
   One of the first stronger special-ability weapons.

### Mid-game targets

- `End Sword`
  Requires `4 End Artifacts`, which drop from endermites, plus `4 Ender Pearl + 1 Iron Sword`
- `Plutonium Blade`
  Requires `Weapons Grade Plutonium`, which starts from rare drops from deepslate coal ore

### Suggested progression

1. Craft `Anduril`
2. Craft `Throwing Knife` or `Copper Sword`
3. Upgrade into `Wither Staff`
4. Farm endermites for `End Sword`
5. Work toward later legendary items like `Plutonium Blade`

## Customising the sever

1. Editing Server Properties
The Minecraft server properties file (server.properties) allows you to configure many aspects of the server. To edit this file:

2. Locate the File:
The server.properties file lives inside the persisted `/data` folder in the container.

This repo now uses a local bind mount at `./minecraft-data:/data`, so you can edit server files directly in the `minecraft-data/` folder on the host.

3. Edit the File:
Open server.properties with a text editor. Here are some common settings you might want to change:
    - motd=Your Server Message: The message of the day displayed in the server list.
    - difficulty=easy: The difficulty level (easy, normal, hard).
    - max-players=20: Maximum number of players.
    - level-seed=: Specify a world seed for terrain generation.

4. Apply Changes:
After making changes, save the file and restart the server:

`docker compose restart`

## Backups

The live server data lives in `./minecraft-data`, so backups can be taken entirely from the repo folder.

For a regular manual backup:

1. Stop the server so world files are not changing during the copy.
2. Run the backup script.
3. Start the server again.

Commands:

`docker compose stop minecraft`

`powershell -ExecutionPolicy Bypass -File .\scripts\backup-minecraft-data.ps1`

`docker compose up -d`

This creates a timestamped zip file in `./backups/`, which is ignored by git.

If you are about to do a risky plugin or version change, it is also worth copying `minecraft-data/` to another disk or cloud location.

# Debugging

Access the sever console:

`docker compose exec minecraft rcon-cli`

If squaremap is installed but the map is blank, restart the container and run the full render command above.

## Rollback

To remove squaremap:

1. Remove the squaremap entry from `plugins.txt`
2. Remove the `8080:8080` port mapping from `docker-compose.yml`
3. Recreate the container with `docker compose up -d`

If you also want to remove squaremap's saved files, delete the squaremap-related content from the persisted `/data/plugins` directory inside the `minecraft-data` volume after stopping the server.

# Pre-requisites

- Docker
