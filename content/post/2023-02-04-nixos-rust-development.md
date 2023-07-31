+++
author = "Mari Donkers"
title = "NixOS Rust development environment (Docker based)"
date = "2023-02-04"
description = "A Rust programming language development environment can be somewhat cumbersome to set up under NixOS (e.g. to use CLevasseur/ta-lib-rust), so a solution using a Docker container is described in this article."
featured = false
tags = [
    "Computer",
    "Software",
    "Rust",
    "NixOS",
    "Docker",
]
categories = [
    "rust",
    "nixos",
    "docker",
]
series = ["NixOS", "Rust", "Docker"]
aliases = ["2023-02-04-nixos-rust-development"]
thumbnail = "/images/rust.svg"
+++

A [Rust](https://www.rust-lang.org/) programming language development environment can be somewhat cumbersome to set up under [NixOS](https://nixos.org/) (e.g. to use [CLevasseur/ta-lib-rust](https://github.com/CLevasseur/ta-lib-rust)), so a solution using a [Docker](https://www.docker.com/) container is described in this article. – [github.com/rust-lang](https://github.com/rust-lang) (by [rust-lang/people](https://github.com/orgs/rust-lang/people)).
<!--more-->

Normally a `shell.nix` as given below suffices to get `rustup` (see e.g. [NixOS Wiki Rust](https://nixos.wiki/wiki/Rust)) but I cannot always get these to work or don't want any unofficial overlays.

`shell.nix` example:

``` nix
# https://nixos.wiki/wiki/Rust

let
  # Pinned nixpkgs, deterministic. 
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "refs/tags/21.11";
  }) {};

  # Rolling updates, not deterministic.
  # pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};

in pkgs.mkShell {
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  shellHook =
    ''
      export PS1="\[\033[01;32m\][\u@\h\[\033[01;37m\] |YourProjectName| \W\[\033[01;32m\]]\$\[\033[00m\] "
    '';

  # buildInputs = [ pkgs.cargo pkgs.rustc ];
  buildInputs = [
    pkgs.rustup
    pkgs.rust-analyzer
  ];
}
```

or a more elaborate one for e.g. Tauri:

``` nix
# https://nixos.wiki/wiki/Rust

let
  # Pinned nixpkgs, deterministic. 
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "refs/tags/21.11";
  }) {};

  # Rolling updates, not deterministic.
  # pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};

in pkgs.mkShell {
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  # buildInputs = [ pkgs.cargo pkgs.rustc ];
  buildInputs = with pkgs; [
    rustup
    pkg-config
    dbus
    openssl
    glib
    gtk3
    libsoup
    webkitgtk
    appimagekit
  ];

  PKGS_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ "libraries" ];
  shellHook =
    ''
      export LD_LIBRARY_PATH="$PKGS_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"
      export PS1="\[\033[01;32m\][\u@\h\[\033[01;37m\] |TauriProjectNameHere| \W\[\033[01;32m\]]\$\[\033[00m\] "
    '';
}
```

Use the Makefile to build the container `make rebuild` and subsequently start the container `make up` and enter a development shell `make shell` which has a `~/Development` binding (change to your path if needed).

# Dockerfile

``` dockerfile
# Rust development environment.

FROM debian:bullseye

# Timezone is also in docker-compose file.
ENV HOME /root
ENV TZ Europe/Amsterdam
ENV SHELL /bin/bash

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y procps sudo curl less vim-nox zip git pkg-config libssl-dev llvm clang build-essential bat exa fd-find; \
    apt-get clean

RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list
RUN apt-get update
# RUN apt-get install -y ta-lib --no-install-recommends

# Create a non-root account with your user's uid and guid.
RUN useradd -ms /bin/bash --uid 1000 --gid 100 rust
# usermod -G audio,video rust;

RUN echo "rust ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install ta-lib.
COPY ta-lib-0.4.0-src.tar.gz ta-lib-0.4.0-src.tar.gz
RUN tar xvzf ta-lib-0.4.0-src.tar.gz ; \
    rm ta-lib-0.4.0-src.tar.gz ; \
    cd ta-lib ; \
    ./configure ; \
    make ; \
    make install

USER rust
WORKDIR /home/rust
ENV HOME /home/rust

# Install and run rustup.
# RUN curl https://sh.rustup.rs -sSf | sh
RUN curl https://sh.rustup.rs -o rustup.sh ; \
    chmod u+x ./rustup.sh ; \
    ./rustup.sh -y

# The DISPLAY variable is required to display on your desktop.
ENV PS1='$ '
ENV DISPLAY=":0"
ENV PATH="$PATH:$HOME/.cargo/bin"

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
  "rustalgotrading":
    image: rust-algotrading
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
      - "~/Development:/home/rust/Development:rw"
      - "~/.Xauthority:/home/rust/.Xauthority:rw"
```

# Makefile

``` makefile
# Brings up the Docker container, which automatically starts a rust
# development environment. The attach can be used to connect to the
# command prompt in the container, where e.g. a Ctrl-c can be used to
# force a stop.
#

NAME="docker-rustalgotrading-1"

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
    curl -O http://deac-fra.dl.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz
    xhost +LOCAL:
    docker-compose build --no-cache

build:
    xhost +LOCAL:
    docker-compose build

attach:
    xhost +LOCAL:
    docker attach $(NAME)

shell:
    xhost +LOCAL:
    docker exec -it $(NAME) /bin/bash

help:
    @grep '^[^  #:]\+:' Makefile | sed -e 's/:[^:]*//g'
    echo "Use make -s for silent execution (e.g. make -s ls)"
```
