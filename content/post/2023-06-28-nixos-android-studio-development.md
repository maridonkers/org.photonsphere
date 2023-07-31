+++
author = "Mari Donkers"
title = "NixOS Android Studio development environment (Docker based)"
date = "2023-06-28"
description = "An Android Studio development environment can be somewhat cumbersome to set up under NixOS, so a solution using a Docker container is described in this article."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "NixOS",
    "Functional Programming",
    "Java",
    "Kotlin",
    "Android",
    "Termux"
]
categories = [
    "development",
    "docker",
    "android",
]
series = ["Linux", "Docker", "Android"]
aliases = ["2023-06-28-nixos-android-studio-development"]
thumbnail = "/images/android.png"
+++

An [Android Studio](https://developer.android.com/studio) development environment can be somewhat cumbersome to set up under [NixOS](https://nixos.org/), so a solution using a [Docker](https://www.docker.com/) container is described in this article.
<!--more-->

Normally instructions at [NixOS Android](https://nixos.wiki/wiki/Android) suffice, but I'm experiencing trouble with additional functionality (e.g. [The Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html)).

Hence this Docker based solution. Use the Makefile to build the container `make rebuild` and subsequently start the container `make up` and enter a development shell `make shell` which has a `~/Development` binding (change to your path if needed). From within the development shell use `/opt/android-studio/bin/studio.sh &` to start Android Studio (its GUI is displayed on your computer — beware: you'll probably need additional configuration if you're using [Wayland](https://wayland.freedesktop.org/)).

# Android Studio

Download the appropriate tarball from [<https://developer.android.com/studio#downloads>](https://developer.android.com/studio#downloads) and save it next to your `Dockerfile` (in the same directory) and adjust the tarball's name in the `Dockerfile` (currently `android-studio-2022.2.1.20-linux.tar.gz`).

`Dockerfile` section:

``` dockerfile
COPY android-studio-2022.2.1.20-linux.tar.gz android-studio-2022.2.1.20-linux.tar.gz 
RUN mkdir -p /opt; \
    tar xvzf android-studio-2022.2.1.20-linux.tar.gz -C /opt
```

# Dockerfile

``` dockerfile
# Android development environment.

FROM debian:latest

# Timezone is also in docker-compose file.
ENV HOME /root
ENV TZ Europe/Amsterdam
ENV SHELL /bin/bash

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y procps sudo curl less vim-nox zip git libssl-dev bat exa fd-find; \
    apt-get clean

RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y openjdk-17-jdk android-sdk --no-install-recommends

# Create a non-root account with your user's uid and guid.
RUN useradd -ms /bin/bash --uid 1000 --gid 100 android
# usermod -G audio,video android;

RUN echo "android ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# https://wiki.debian.org/AndroidStudio
# /opt/android-studio/bin/studio.sh &
#
COPY android-studio-2022.2.1.20-linux.tar.gz android-studio-2022.2.1.20-linux.tar.gz 
RUN mkdir -p /opt; \
    tar xvzf android-studio-2022.2.1.20-linux.tar.gz -C /opt

USER android
WORKDIR /home/android
ENV HOME /home/android

# The DISPLAY variable is required to display on your desktop.
ENV PS1='$ '
ENV DISPLAY=":0"

# For access to X-server use the following command:
#   xhost +LOCAL:
#
# RUN todo
ENTRYPOINT ["/bin/bash"]
```

# docker-compose.yaml

``` docker-compose
version: "2.0"
services:
  "android":
    image: android-dev
    build: .
    stdin_open: true
    tty: true
    privileged: true
    ipc: host
    environment:
      - TZ=Europe/Amsterdam
    network_mode: host
    volumes:
      - "/tmp/.X11-unix/:/tmp/.X11-unix/:ro"
      - "~/Development:/home/android/Development:rw"
      - "~/.Xauthority:/home/android/.Xauthority:rw"
```

# Makefile

``` makefile
# Brings up the Docker container, which automatically starts an Android
# development environment. The attach can be used to connect to the
# command prompt in the container, where e.g. a Ctrl-c can be used to
# force a stop.
#

NAME="docker-android-1"

all: help

up:
    xhost +LOCAL:
    docker-compose up -d

down:
    sync
    docker-compose down

# If problems persist after a force-down then manually restart Docker daemon.
force-down:
    sync
    docker rm -f $(NAME)

ls:
    docker ps -a

rebuild:
    xhost +LOCAL:
    docker-compose build --no-cache

build:
    xhost +LOCAL:
    docker-compose build

attach:
    xhost +LOCAL:
    docker attach $(NAME)

shell:
    #xhost +LOCAL:
    docker exec -it $(NAME) /bin/bash

help:
    @grep '^[^  #:]\+:' Makefile | sed -e 's/:[^:]*//g'
    @echo "Use make -s for silent execution (e.g. make -s ls)"
    @echo "To start Android studio use make shell for an interactive shell and type the following command:"
    @echo "/opt/android-studio/bin/studio.sh &"
```

# Demonstration

See the screendump below.

![](/images/AndroidStudioInDocker.jpg)
