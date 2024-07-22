+++
author = "Mari Donkers"
title = "Debian + Propellor"
date = "2024-07-13"
description = "Recent NixOS governance developments made me move from NixOS to Debian + Propellor."
featured = false
tags = [
    "Computer",
    "Software",
    "NixOS",
    "Haskell",
    "Propellor",
    "Debian",
]
categories = [
    "linux",
    "haskell",
    "static site generator"
]
series = ["Propellor", "Debian", "NixOS", "Linux", "Haskell"]
aliases = ["2024-07-13-propellor"]
thumbnail = "/images/debian.svg"
+++

The [Propellor](https://propellor.branchable.com/) configuration management system uses Haskell and Git. Each system has a list of properties, which Propellor ensures are satisfied. [Linux](http://propellor.branchable.com/Linux/) and [FreeBSD](http://propellor.branchable.com/FreeBSD/) are supported.
<!--more-->
# Debian
I use `Propellor` to manage my `Debian` installation (it replaced my `NixOS` installation — which I reconsidered because of this: [abdication of founder](https://lunduke.locals.com/post/5819317/nixos-commits-a-purge-of-nazi-contributors-forces-abdication-of-founder))

I'll probably continue to use the [Nix](https://nix.dev/manual/nix/2.18/) package manager, but from a `Debian` shell.

# Setup

Install `propellor` as follows:

``` sh
apt install propellor
```

Initialize it as follows (this creates `~/.propellor` subdirectory):

``` sh
propellor --init
```

*Do not yet attempt to run propellor!*

Remove `.propellor/config.hs` and replace it with your own (mine is on <GitHub>); also change `propellor.cabal` to include additional source files (mine are in a `lib` subdirectory) — don't forget to add to git via a `git add filename` command, prior to first run of propellor (appears to be recoverable only by removing `/usr/local/propellor` subdirectory as root).

Configuration of `/etc/ssh/sshd_config` may need changing from its default to run `propellor`. Also see my configuration in <GitHub>.

# Usage

``` sh
propellor
```

# GitHub

[maridonkers/propellor-debian](https://github.com/maridonkers/propellor-debian)
