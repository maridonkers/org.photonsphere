+++
author = "Mari Donkers"
title = "xmonad with xterm"
date = "2021-11-15"
description = "In the past I have used the xmonad tiling window manager but eventually returned to KDE, because I had some problems with truncated text in terminal windows, needed to be able to run a complicated GUI that was not very suited for a tiling window manager and I thought there was not that much difference in performance."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "KDE",
    "Tiling Window Manager",
    "XMonad",
    "Haskell",
    "GUI",
]
categories = [
    "linux",
    "haskell",
]
series = ["Linux", "Haskell"]
aliases = ["2021-11-13-xmonad-and-screen-zombies"]
thumbnail = "/images/kde.svg"
+++

In the past I have used the [xmonad](https://xmonad.org/) tiling window manager but eventually returned to [KDE](https://kde.org/), because I had some problems with truncated text in terminal windows, needed to be able to run a complicated GUI that was not very suited for a [tiling window manager](https://en.wikipedia.org/wiki/Tiling_window_manager) and I thought there was not that much difference in performance.
<!--more-->

# xmonad, xmobar

## Introduction

The documentation reads that the [xmonad](https://xmonad.org/) tiling window manager is fast and configurable; [xmobar](https://xmobar.org/) - a minimalistic status bar.

## terminal emulator

### xterm

The [xterm](https://en.wikipedia.org/wiki/Xterm) terminal emulator starts up very quickly and for me this compensates for its lack of tabs. Besides: `tmux` can be configured to use tabs. Note: to select things with the mouse in `tmux`, press the Shift key when using the mouse.

`~/.tmux.conf`

``` bash
set-option -g prefix C-z
unbind-key C-b
bind-key C-z send-prefix
set -g mouse on
set -g history-limit 9999
set -g default-terminal "screen-256color"

# https://gist.github.com/william8th/faf23d311fc842be698a1d80737d9631
# Set new panes to open in current directory
# bind c new-window -c "#{pane_current_path}"
# bind '"' split-window -c "#{pane_current_path}"
# bind % split-window -h -c "#{pane_current_path}"

# https://www.seanh.cc/2020/12/30/how-to-make-tmux's-windows-behave-like-browser-tabs/#:~:text=Key%20bindings&text=conf%20file%20to%20get%20browser,and%20C%2DS%2DTab%20in%20tmux.
set -g base-index 1       # Start numbering windows at 1, not 0.
set -g pane-base-index 1  # Start numbering panes at 1, not 0.
bind -n C-t new-window
bind -n C-PgDn next-window
bind -n C-PgUp previous-window
bind -n C-S-Left swap-window -t -1\; select-window -t -1
bind -n C-S-Right swap-window -t +1\; select-window -t +1
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t:$
bind -n C-M-w kill-window
bind -n C-M-q confirm -p "Kill this tmux session?" kill-session
bind -n F11 resize-pane -Z

set -g status-style "bg=default"
set -g window-status-current-style "bg=default,reverse"
set -g window-status-separator ''  # No spaces between windows in the status bar.
set -g window-status-format "#{?window_start_flag,, }#I:#W#{?window_flags,#F, } "
set -g window-status-current-format "#{?window_start_flag,, }#I:#W#{?window_flags,#F, } "
```

### xterm

In the `xmonad.hs` configuration file the following code is used to define a terminal and a floating terminal with the `xterm` command.

``` haskell
myTerminal :: String
myTerminal = "xterm"

myFloatingTerminal :: String
myFloatingTerminal = "xterm -title \"floatterm\""

--...

keysAdditional =
    [ ("M-C-<Return>", spawn myFloatingTerminal)
    ,

-- ...
  xmonad $ def {
    terminal = myTerminal,
```

# Performance gains

My system is indeed ****significantly**** snappier and faster in general under [xmonad](https://xmonad.org/) than it was under [KDE](https://kde.org/) and I now don't quite understand how I came to a different conclusion before. It must have been annoyance-bias over the terminal output truncate problem.

# dotfiles

My [dotfiles](https://github.com/maridonkers/dotfiles) at GitHub with a.o. [xmonad](https://github.com/maridonkers/dotfiles/tree/master/xmonadconfig), [xmobar](https://github.com/maridonkers/dotfiles/tree/master/.config/xmobar) configuration.

# Already on GitHub

- [NixOS configuration](https://github.com/maridonkers/nixos-configuration)
- [Emacs configuration](https://github.com/maridonkers/emacs-config)
