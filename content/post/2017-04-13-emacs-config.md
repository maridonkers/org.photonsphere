+++
author = "Mari Donkers"
title = "My Emacs configuration"
date = "2017-04-13"
description = "My emacs-config, which is using org-mode and has been based on Arjen Wiersma's emacs-config, Sacha Chua's Emacs Configuration, Daniel Mai's Mai Emacs Configuration and Uncle Dave's Emacs configuration."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Linux",
    "IDE",
    "Editor",
    "Emacs",
    "Lisp",
]
categories = [
    "editor",
    "emacs",
]
series = ["Emacs", "Editors"]
aliases = ["2017-04-13-emacs-config"]
thumbnail = "/images/emacs.svg"
+++

My [emacs-config](https://github.com/maridonkers/emacs-config), which is using [org-mode](http://orgmode.org/) and has been based on Arjen Wiersma's [emacs-config](https://gitlab.com/buildfunthings/emacs-config), Sacha Chua's [Emacs Configuration](http://pages.sachachua.com/.emacs.d/Sacha.html), Daniel Mai's [Mai Emacs Configuration](https://github.com/danielmai/.emacs.d) and [Uncle Dave's Emacs](https://github.com/daedreth/UncleDavesEmacs/blob/master/config.org) configuration.
<!--more-->

# Beware

Still debugging (my version, not theirs); tested only (my version) with Emacs 25.{1,2} under Linux.

# Usage

- rename your existing \~/.emacs.d directory as a backup;
- check that there's no \~/.emacs file (rename it if there is);
- git clone <https://github.com/maridonkers/emacs-config.git> \~/.emacs.d

Start Emacs and wait until packages are all retrieved and installed.

# Emacs daemon

Setting up an Emacs daemon makes it start almost instantaneously! Under Linux the start/stop can be done via systemd, as follows:

In file: *\~*.config/systemd/user/emacs.service/

``` ini
# Usage: systemctl --user {enable,disable,start,restart,stop} emacs.service
#

[Unit]
Description=Emacs: the extensible, self-documenting text editor

[Service]
Type=forking
ExecStart=/usr/bin/emacs --daemon
ExecStop=/usr/bin/emacsclient --eval "(progn (setq kill-emacs-hook 'nil) (kill-emacs))"
Restart=always

# Remove the limit in startup timeout, since emacs
# cloning and building all packages can take time
TimeoutStartSec=0

[Install]
WantedBy=default.target
```

# Reload systemd user configuration

``` bash
systemctl daemon-reload --user
```

# Make your PATH known to systemd

If you customize your PATH and plan on launching applications that make use of it from systemd units, you should make sure the modified PATH is set on the systemd environment. The best way to make systemd aware of your modified PATH is by adding the following after the PATH variable is set:

``` bash
systemctl --user import-environment PATH
```

# Start, restart, stop Emacs daemon

Use respectively:

``` bash
systemctl --user start emacs.service

systemctl --user restart emacs.service

systemctl --user stop emacs.service
```

# Automatically start Emacs daemon at login

``` bash
systemctl --user enable emacs.service
```

# Start Emacs as client

Now the Emacs daemon is running you can start an Emacs client, e.g. as follows:

``` bash
emacsclient -nc
```

(with optional filename(s) as additional parameters).

BTW: You can skip all the `systemd` configuration and just start `emacsclient` as follows:

``` bash
emacsclient -nc -a "" 
```
