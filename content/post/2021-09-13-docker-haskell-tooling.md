+++
author = "Mari Donkers"
title = "Haskell tooling in a Docker container"
date = "2021-09-13"
description = "Create a Docker image with Debian Linux in which you can install and use Haskell tooling (e.g. Stack) and that uses your computer's native GUI. This can be useful because using Stack under NixOS can be somewhat cumbersome."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "NixOS",
    "Functional Programming",
    "Haskell",
    "Docker",
]
categories = [
    "linux",
    "haskell",
    "docker"
]
series = ["Linux", "Haskell", "Docker"]
aliases = ["2021-09-13-docker-haskell-tooling"]
thumbnail = "/images/haskell.svg"
+++

Create a [Docker](https://www.docker.com/) image with [Debian](https://www.debian.org/) Linux in which you can install and use Haskell tooling (e.g. [Stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/)) and that uses your computer's native GUI. This can be useful because using Stack under [NixOS](https://nixos.org/) can be somewhat cumbersome.
<!--more-->

On the Docker host computer, if you run the container manually, do not forget to use `xhost` to allow access to the X-server, as follows.

``` bash
xhost +LOCAL:
```

See the `Makefile` for an easier way to to build and start the container.

The below project is on github: [maridonkers/haskell-tooling-docker](https://github.com/maridonkers/haskell-tooling-docker). I use it under NixOS.

# Shared files with container

This is done via bind mounts for the `~/src` and `~/Development` subdirectories (change these for your environment). Check if your uid is 1000 via the `id` command. If it is not then find and change all uid instances in the files of the project and change the 1000 to your uid value.

# Define the image via a Dockerfile

The `Dockerfile`:

``` dockerfile
# Haskell tooling (a.o. stack & cabal) in a Docker container.
# See e.g.: https://docs.haskellstack.org/en/stable/install_and_upgrade/
# To manually set up your tooling from within this container (`make shell`).

FROM debian:latest

# Timezone is also in docker-compose file.
ENV HOME /root
ENV TZ Europe/Amsterdam
ENV SHELL /bin/bash

# Install dependencies that are likely required for the tooling.
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y procps lsof sudo curl less vim-nox zip git build-essential \
                       g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils \
                       pkg-config zlib1g-dev git gnupg netbase; \
    apt-get clean

RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list

# https://vsupalov.com/docker-build-pass-environment-variables/
# ARG DOCKER_HASKELL_PASSWORD
# ENV ENV_DOCKER_HASKELL_PASSWORD=$DOCKER_HASKELL_PASSWORD

# Create a non-root account to run Haskell tooling with.
RUN useradd -ms /bin/bash --uid 1000 --gid 100 haskell; \
    usermod -G audio,video,sudo haskell; \
    echo "haskell:putapasswordhereforsudo" | chpasswd
    # TODO Doesn't work?
    # echo "haskell:$ENV_DOCKER_HASKELL_PASSWORD" | chpasswd

USER haskell
WORKDIR /home/haskell
RUN mkdir -p /home/haskell/bin
ENV HOME /home/haskell
ENV PATH="${PATH}:/home/haskell/bin:/home/haskell/.local/bin"
ENV LC_ALL=C.UTF-8
ENV DISPLAY=":0"

# ENTRYPOINT ["/bin/bash"]
```

# The Docker compose file

``` dockerfile
version: "2.0"
services:
  "haskell":
    image: tooling-haskell
    build: .
    stdin_open: true
    tty: true
    privileged: true
    ipc: host
    # https://docs.docker.com/compose/environment-variables/
    # TODO Doesn't work?
    environment:
      - TZ=Europe/Amsterdam
      # - ENV_DOCKER_HASKELL_PASSWORD=${DOCKER_HASKELL_PASSWORD}
    network_mode: host
    volumes:
      - "./.stack/:/home/haskell/.stack/:rw"
      - "./.cabal:/home/haskell/.cabal:rw"
      - "./.local/:/home/haskell/.local/:rw"
      - "./usr/local/:/usr/local/:rw"
      - "~/src/:/home/haskell/src/:rw"
      - "~/Development/:/home/haskell/Development/:rw"
      - "~/.Xauthority:/home/haskell/.Xauthority:rw"
      - "/tmp/.X11-unix/:/tmp/.X11-unix/:ro"
```

# Makefile

Use the `make` command to build the Docker container and bring it up. The `Makefile` is shown below. Initially use `make rebuild` to create the container. Then simply use `make` to run it in the background and `make shell` for an interactive shell. To bring it down completely, use `make down`.

``` makefile
# Brings up the Haskell Tooling as a Docker container.
# Use make shell to get an interactive shell.
#

CONTAINER="docker_haskell_1"

all: up 

up:
    xhost +LOCAL:
    mkdir -p .cabal .local .stack usr/local
    docker-compose up --detach

down:
    sync
    docker-compose down

# If problems persist after a force-down then manually restart Docker daemon.
force-down:
    sync
    docker rm -f $(CONTAINER)

ls:
    docker ps -a

images:
    docker images

rebuild:
    docker-compose build --no-cache

build:
    docker-compose build

attach:
    xhost +LOCAL:
    docker attach $(CONTAINER)

shell:
    xhost +LOCAL:
    docker exec -it $(CONTAINER) /bin/bash
```
