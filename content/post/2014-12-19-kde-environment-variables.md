+++
author = "Mari Donkers"
title = "KDE environment variables"
date = "2014-12-19"
description = "The KDE desktop environment supports environment variables. These are active when logged in to KDE. Contrary to regular bash environment variables, which are active only when a bash shell is started."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "KDE",
    "GUI",
    "Shell Script",
]
categories = [
    "linux",
]
series = ["Linux"]
aliases = ["2014-12-19-kde-environment-variables"]
thumbnail = "images/linux.jpg"
+++

The KDE desktop environment supports environment variables. These are active when logged in to KDE. Contrary to regular bash environment variables, which are active only when a bash shell is started.
<!--more-->

To set KDE environment variables create a file in the `.kde4/env` or `.kde/env` directory, e.g. as follows:

``` bash
export MOZILLA_FIVE_HOME="/opt/firefox"
```
