# Debian-MediaWiki

Revamping my [previous work with Alpine](https://github.com/aixnr/alpine-mediawiki) to using Debian as the base operating system for generating custom Docker containers for deploying a MediaWiki instance.

## Required Packages on Host

Install Docker and `docker-compose` according to the official installation guide.

## Building Custom MediaWiki Docker Image

Locate the `docker-compose.yml` then run the following command in the same directory.

```bash
# Run, spit endlessly to terminal
$ docker-compose up

# Run daemonized
$ docker-compose up -d
```

At the end of setting up, download `LocalSettings.php` from the MediaWiki web installer (you won't miss it because it will ask), then place it inside the same directory as the `docker-compose.yml`, and add the following directive under `volumes:` for the `mediawiki` container.

```yml
-  ./LocalSettings.php:/var/www/mediawiki/LocalSettings.php
```

Then, stop the container (`ctrl` + `c` if not daemonized, see below if daemonize) then start the containers again through `docker-compose`. This time, the MediaWiki application would read the content of the `LocalSettings.php` and it should run as configured.

To stop running, run:

```bash
# Bring down compose
$ docker-compose down
$ docker-compose rm

# Hard reset, first list volumes, then prune them all
$ docker volume ls 
$ docker volume prune
```

## Troubleshoting

Enter into an already-running container with the following Docker command:

```bash
$ docker exec -it <container ID> bash
```

To stop and delete all containers (not container images!)

```bash
# Stop them all
$ docker stop $(docker ps -a q)

# Delete them all
$ docker rm $(docker ps -a -q)
```
