+++
author = "Mari Donkers"
title = "Suspend/Resume problems Docker containers"
date = "2016-09-13"
description = "Once upon a time, while using Debian I had a problem with Docker containers and suspend/resume."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "Shell Script",
    "Docker",
    "KDE",
    "GUI",
]
categories = [
    "linux",
    "docker",
]
series = ["Linux", "Docker"]
aliases = ["2016-09-13-suspendresume-problems-docker-containers"]
thumbnail = "images/docker.svg"
+++

Once upon a time, while using Debian I had a problem with Docker containers and suspend/resume.

# Docker resume/thaw problems?

When you use [Docker](https://www.docker.com/) containers on your development system and experience problems after a resume from a suspend (or a thaw from a hibernate). On my Debian Stable KDE system –after a resume of my [MongoDB](https://www.mongodb.com/) and [WildFly](http://wildfly.org/) containers– the screensaver did not ask for a password and the computer did not respond to mouse and keyboard.
<!--more-->

# Fix via pm-utils script

A pm-utils script can be added to pause all running Docker containers on suspend /hibernate and unpause them on resume/thaw. Create a file `/usr/lib/pm-utils/sleep.d/00docker` with following content:

``` bash
#!/bin/sh
. "${PM_FUNCTIONS}"
command_exists docker || exit $NA
# Pause all running docker containers on suspend|hibernate and unpause on resume|thaw.
case $1 in
    suspend|hibernate) docker pause $(docker ps -q) ;;
    resume|thaw)       docker unpause $(docker ps -q) ;;
    *) exit $NA ;;
esac
exit 0
```
