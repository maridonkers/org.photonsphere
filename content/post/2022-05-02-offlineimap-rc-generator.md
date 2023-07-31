+++
author = "Mari Donkers"
title = "A generator that updates certificate fingerprints in .offlineimaprc"
date = "2022-05-02"
description = "A generator that updates `cert_fingerprint` lines in `.offlineimaprc` configuration file."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "Internet",
    "EMail",
    "Protocol",
    "IMAP",
]
categories = [
    "linux",
    "haskell",
    "protocol",
]
series = ["Linux", "Haskell", "Protocol"]
aliases = ["2022-05-02-offlineimap-rc-generator"]
thumbnail = "/images/haskell.svg"
+++

A generator that updates `cert_fingerprint` lines in `.offlineimaprc` configuration file. [OfflineIMAP](http://www.offlineimap.org/) is a GPLv2 software to dispose your mailbox(es) as a local Maildir(s), which can be used with [notmuch](https://notmuchmail.org/) to retrieve mail from (several) `IMAP` servers and read and search through it.

The configuration contains `cert_fingerprint` lines to store certificates, which get outdated frequently and need to be updated. The updating is a bit of a hassle, hence this automated solution, which generates a `.offlineimaprc` file from a template file `.offlineimaprct` (created by you).
<!--more-->

# GUIs, TUIs and CLUIs

Although I strongly adhere to the "when there a TUI, don't use a GUI and when there's a CLUI, don't use a TUI" adage, there are good GUIs for web browsing and e-mail. But `OfflineIMAP` creates a great local backup of the e-mails on your server, which can be searched through very fast using `notmuch`.

# Turtle and openssl

## Turtle

[Turtle](https://github.com/Gabriel439/turtle) is a reimplementation of the Unix command line environment in Haskell so that you can use Haskell as a scripting language or a shell. Think of turtle as coreutils embedded within the [Haskell](https://www.haskell.org/) language.

## openssl

[OpenSSL](https://github.com/openssl/openssl) is a robust, commercial-grade, full-featured Open Source Toolkit for the Transport Layer Security (TLS) protocol formerly known as the Secure Sockets Layer (SSL) protocol. The protocol implementation is based on a full-strength general purpose cryptographic library, which can also be used stand-alone.

The openssl command that is used by the generator to retrieve certificate fingerprints is as follows:

``` bash
openssl s_client -connect youremailserverbasedomain:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin
```

# Backup your OflineIMAP configuration

First backup your `.offlineimaprc` configuration file! e.g. As follows:

    cp ~/.offlineimaprc ~/.offlineimaprc.backup

# .offlineimaprct template

Copy your `.offlineimaprc` file to `.offlineimaprct` and execute the generator program. Use the `-v` option to get verbose output.

`.offlineimaprct` (example)

``` example
# Sample configuration file
# Copyright (C) 2002-2011 John Goerzen & contributors
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Looking for a quick start?  Take a look at offlineimap.conf.minimal.

##################################################
# General definitions
##################################################

[general]
metadata = ~/.offlineimap
accounts = Contact,Private

# Set to the number of accounts.
maxsyncaccounts = 2

ui = machineui 
ignore-readonly = no
[mbnames]
enabled = no
filename = ~/Mutt/muttrc.mailboxes
header = "mailboxes "
peritem = "+%(accountname)s/%(foldername)s"
sep = " "
footer = "\n"
[ui.Curses.Blinkenlights]
statuschar = .
postsynchook = ~/bin/offlineimap-postsync.sh

##################################################
# Accounts
##################################################

[Account Contact]
localrepository = LocalContact
remoterepository = RemoteContact
[Repository LocalContact]
type = Maildir
localfolders = ~/notmuch/contact
sep = .
restoreatime = no
[Repository RemoteContact]
type = IMAP
remotehost = mail.contactdomainname.com
ssl = yes
cert_fingerprint = hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh
remoteuser = contact@contactdomainname.com
remotepass = passwordgoeshere
maxconnections = 2
holdconnectionopen = no
subscribedonly = no
readonly = True

[Account Private]
localrepository = LocalPrivate
remoterepository = RemotePrivate
[Repository LocalPrivate]
type = Maildir
localfolders = ~/notmuch/private
sep = .
restoreatime = no
[Repository RemotePrivate]
type = IMAP
remotehost = mail.privatedomainname.com
ssl = yes
cert_fingerprint = hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh:hh
remoteuser = private@privatedomainname.com
remotepass = passwordgoeshere
maxconnections = 2
holdconnectionopen = no
subscribedonly = no
readonly = True
```

# Cloning the project and its submodules

``` bash
git clone --recurse-submodules https://github.com/maridonkers/OfflineImapGenerator
```

If the `publicsuffix-haskell` submodule is not created, then clone it manually, as follows:

``` bash
cd OfflineImapGenerator
git clone https://github.com/wereHamster/publicsuffix-haskell/
```

Note: `publicsuffix-haskell` is in a submodule because you may want to bump it (use `script/bump`) to a more recent [Public Suffix List](https://publicsuffix.org/).

# Building and executing

See the [Makefile](https://github.com/maridonkers/OfflineImapGenerator/blob/master/offlineimapgenerator/Makefile). Under [NixOS](https://nixos.org/) first use a `make shell` before the other `make` commands.

``` bash
cd OfflineImapGenerator/offlineimapgenerator
make rebuild
make run
```

To get a full path to the built executable use `make ls` and e.g. `ln -s` to create a symbolic link.

See the source code at [maridonkers/OfflineImapGenerator](https://github.com/maridonkers/OfflineImapGenerator) on GitHub.

# Disclaimer

This is a 'one shot' program (excuse my Haskell) that I'm using myself but have not checked extensively, not cleaned up the code. If I find some time or run into bugs then I'll clean it up (probably).
