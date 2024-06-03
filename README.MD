# Introduction

A simple little experiment to create a docker container for hosting a minecraft server. Evenetually we want to be able to either run this locally in:

- A Rasperry Pi and portainer
- A local synology NAS drive with containers enabled

# How to run

To run this, simply type:

`docker-compose up -d`

# Further changes

You can do more with this!

## Customising the sever

1. Editing Server Properties
The Minecraft server properties file (server.properties) allows you to configure many aspects of the server. To edit this file:

2. Locate the File:
The server.properties file is located in the ./minecraft-data directory that you mapped in the docker-compose.yml.

3. Edit the File:
Open server.properties with a text editor. Here are some common settings you might want to change:
    - motd=Your Server Message: The message of the day displayed in the server list.
    - difficulty=easy: The difficulty level (easy, normal, hard).
    - max-players=20: Maximum number of players.
    - level-seed=: Specify a world seed for terrain generation.

4. Apply Changes:
After making changes, save the file and restart the server:

    `
    docker-compose restart
    `

# Debugging

Access the sever console:

`docker-compose exec minecraft rcon-cli`

# Pre-requisites

- Docker