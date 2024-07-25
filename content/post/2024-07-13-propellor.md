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
I use Propellor to manage my `Debian` installation (it replaced my `NixOS` installation — which I reconsidered because of this: [abdication of founder](https://lunduke.locals.com/post/5819317/nixos-commits-a-purge-of-nazi-contributors-forces-abdication-of-founder))

# Setup

Install Propellor as follows:

``` sh
apt install propellor
```

As a regular user, initialize Propellor as follows (this creates `~/.propellor` subdirectory):

``` sh
propellor --init
```

**Do not yet attempt to run propellor!**

First remove `.propellor/config.hs` and replace it with your own (mine is on GitHub); also change `propellor.cabal` to include additional source files (mine are in a `lib` subdirectory) — don't forget to add any additional files to git via a `git add filename` command, prior to a first or next run of propellor (failure to do so appears to be recoverable only by removing `/usr/local/propellor` subdirectory as root). Then try to run `propellor`.

Configuration of `/etc/ssh/sshd_config` may need changing from its default to run `propellor`. Also see my configuration in GitHub.

# Usage

To compile your configuration but not install it, use this:
``` sh
propellor --build
```

To compile and install your configuration, use this:
``` sh
propellor
```

# Configuration
API documentation for the configuration of Propellor is here: [Propellor API documentation](https://hackage.haskell.org/package/propellor).

# Quirks

Propellor typically only acts to ensure a property is met, it normally does not unact. If e.g. you have the Propellor cron functionality and remove it from your `config.hs` then it will no longer be installed on subsequent Propellor runs, but you'll have to remove it manually from `/etc/cron.d` to uninstall it. This may also apply to other and your own configuration you added.

# GitHub

[maridonkers/propellor-debian](https://github.com/maridonkers/propellor-debian)
