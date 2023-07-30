+++
author = "Mari Donkers"
title = "Haskell development environment on Android phone"
date = "2021-11-18"
description = "Install a full Haskell development environment (including hpack and cabal) on your Android phone."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "NixOS",
    "Functional",
    "Haskell",
    "Android",
    "Termux"
]
categories = [
    "development",
    "docker",
]
series = ["Docker"]
aliases = ["2021-11-18-haskell-development-android"]
thumbnail = "images/building.png"
+++

Install a full [Haskell](https://www.haskell.org/) development environment (including [hpack](https://github.com/sol/hpack) and [cabal](https://www.haskell.org/cabal/)) on your [Android](https://www.android.com/) phone. The command prompt runs via [Termux](https://f-droid.org/en/packages/com.termux/) and its [PRoot](https://wiki.termux.com/wiki/PRoot) (i.e. [proot-distro](https://github.com/termux/proot-distro)).
<!--more-->

# F-Droid

Install F-Droid from [f-droid.org](https://www.f-droid.org/) (follow instructions).

# Termux + PRoot

First install the [Termux](https://f-droid.org/en/packages/com.termux/) package via <span class="spurious-link" target="F-Droid">*F-Droid*</span> and then follow the [PRoot](https://wiki.termux.com/wiki/PRoot) instructions to install a Linux distribution on your phone (I use [Debian](https://www.debian.org/)).

``` bash
pkg install proot
pkg install proot-distro
proot-distro install debian
```

After installation has completed use the following to get a Debian prompt:

``` bash
proot-distro login debian
```

# Debian packages

A number of Debian packages are required and useful for your Haskell development environment. To install them start up Debian Linux under Termux (per instructions with <span class="spurious-link" target="Termux + PRoot">*PRoot*</span>) and type the following commands:

``` bash
apt-get update
apt-get install build-essential curl vim-nox silversearcher-ag git ghc cabal-install hpack hlint stylish-haskell pkgconf libghc-zlib-dev libghc-text-icu-dev libpq-dev
```

# Demonstration

Use the commands below to get and build my Paperspan export (HTML) to Instapaper import (CSV) convertor – [Paperspan export (HTML) to Instapaper import (CSV) convertor](https://photonsphere.org/posts/2021-10-06-paperspan2instapaper.html).

``` bash
git clone https://github.com/maridonkers/paperspan2instapaper.git
cd paperspan2instapaper
cabal update
hpack
cabal build
cp folders-example.yaml folders.yaml
cabal run . -- yourpaperspanexportfile.html
```

Notes:

- • Depending on your phone the `cabal new-update` and `cabal new-build` may take a while to complete.
- • If the build fails then simply start it again (I had to start it again once).

# Keys menu and colors

Configuration of useful keys in the keys menu and readable colors via `Termux` configuration files.

## Termux configuration

`~/.termux/termux.properties`

``` example
### After making changes and saving you need to run `termux-reload-settings`
### to update the terminal.  All information here can also be found on the
### wiki: https://wiki.termux.com/wiki/Terminal_Settings

###############
# General
###############

### Allow external applications to execute arbitrary commands within Termux.
### This potentially could be a security issue, so option is disabled by
### default. Uncomment to enable.
# allow-external-apps = true

### Default working directory that will be used when launching the app.
# default-working-directory = /data/data/com.termux/files/home

### Uncomment to disable toasts shown on terminal session change.
# disable-terminal-session-change-toast = true

### Uncomment to not show soft keyboard on application start.
# hide-soft-keyboard-on-startup = true

### Uncomment to let keyboard toggle button to enable or disable software
### keyboard instead of showing/hiding it.
# soft-keyboard-toggle-behaviour = enable/disable

### Adjust terminal scrollback buffer. Max is 50000. May have negative
### impact on performance.
# terminal-transcript-rows = 2000

### Uncomment to use volume keys for adjusting volume and not for the
### extra keys functionality.
# volume-keys = volume

###############
# Fullscreen mode
###############

### Uncomment to let Termux start in full screen mode.
# fullscreen = true

### Uncomment to attempt workaround layout issues when running in
### full screen mode.
# use-fullscreen-workaround = true

###############
# Cursor
###############

### Cursor blink rate. Values 0, 100 - 2000.
# terminal-cursor-blink-rate = 0

### Cursor style: block, bar, underline.
# terminal-cursor-style = block

###############
# Extra keys
###############

### Settings for choosing which set of symbols to use for illustrating keys.
### Choose between default, arrows-only, arrows-all, all and none
# extra-keys-style = default

### Force capitalize all text in extra keys row button labels.
# extra-keys-text-all-caps = true

### Default extra-key configuration
#extra-keys = [[ESC, TAB, CTRL, SPACE, {key: '-', popup: '|'}, LEFT, DOWN, UP, RIGHT]]
extra-keys = [[ESC, CTRL, TAB, '|', '/', '~', SPACE, LEFT, UP, DOWN, RIGHT]]

### Two rows with more keys
# extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'], \
#               ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

### Configuration with additional popup keys (swipe up from an extra key)
# extra-keys = [[ \
#   {key: ESC, popup: {macro: "CTRL f d", display: "tmux exit"}}, \
#   {key: CTRL, popup: {macro: "CTRL f BKSP", display: "tmux ←"}}, \
#   {key: ALT, popup: {macro: "CTRL f TAB", display: "tmux →"}}, \
#   {key: TAB, popup: {macro: "ALT a", display: A-a}}, \
#   {key: LEFT, popup: HOME}, \
#   {key: DOWN, popup: PGDN}, \
#   {key: UP, popup: PGUP}, \
#   {key: RIGHT, popup: END}, \
#   {macro: "ALT j", display: A-j, popup: {macro: "ALT g", display: A-g}}, \
#   {key: KEYBOARD, popup: {macro: "CTRL d", display: exit}} \
# ]]

###############
# Colors/themes
###############

### Force black colors for drawer and dialogs
# use-black-ui = true
use-black-ui = true

###############
# HW keyboard shortcuts
###############

### Disable hardware keyboard shortcuts.
# disable-hardware-keyboard-shortcuts = true

### Open a new terminal with ctrl + t (volume down + t)
# shortcut.create-session = ctrl + t

### Go one session down with (for example) ctrl + 2
# shortcut.next-session = ctrl + 2

### Go one session up with (for example) ctrl + 1
# shortcut.previous-session = ctrl + 1

### Rename a session with (for example) ctrl + n
# shortcut.rename-session = ctrl + n

###############
# Bell key
###############

### Vibrate device (default).
# bell-character = vibrate

### Beep with a sound.
# bell-character = beep

### Ignore bell character.
# bell-character = ignore

###############
# Back key
###############

### Send the Escape key.
# back-key=escape

### Hide keyboard or leave app (default).
# back-key=back

###############
# Keyboard issue workarounds
###############

### Letters might not appear until enter is pressed on Samsung devices
# enforce-char-based-input = true

### ctrl+space (for marking text in emacs) does not work on some devices
# ctrl-space-workaround = true
```

## The color theme

`~/.termux/colors.properties`

``` example
background:     #000000
foreground:     #F8F8F2

color0:         #000000
color8:         #4D4D4D

color1:         #F1FA8C
color9:         #F4F99D

color2:         #50FA7B
color10:        #5AF78E

color3:         #F08080
color11:        #FF6E67

color4:         #8BE9FD
color12:        #9AEDFE

color5:         #FF79C6
color13:        #FF92D0

color6:         #BD93F9
color14:        #CAA9FA

color7:         #BFBFBF
color15:        #E6E6E6
```

# Termux sessions

If you require additional command prompts then simply swipe in from the left of the Termux window, to get the menu.

![](/images/TermuxSessions.png)

Select `NEW SESSION` in the menu.

# OpenSSH and GUI

## sshd

Modern phones are multi-core powerhouses with loads of memory and I've compiled big projects on my 2013 phone (a Samsung Note 3). The small on screen keyboard is a bit of a nuisance so you can run a SSH-server on your phone and ssh into it from a computer with a regular keyboard. Termux documentation is here: [Remote Access](https://wiki.termux.com/wiki/Remote_Access).

## GUI

You can also set up a graphical environment for your Termux installation, which enables you to run graphical programs from your termux prompt. Instructions here: [Graphical Environment](https://wiki.termux.com/wiki/Graphical_Environment).

# Screen dump

![](/images/TermuxLinuxDemo.png)
