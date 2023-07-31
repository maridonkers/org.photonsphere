+++
author = "Mari Donkers"
title = "Specific compiler switches per package in Gentoo"
date = "2015-01-03"
description = "To configure specific compiler switches per package in Gentoo use these instructions."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "Gentoo",
]
categories = [
    "linux",
]
series = ["Linux"]
aliases = ["2015-01-03-specific-compiler-switches-per-package-in-gentoo"]
thumbnail = "/images/linux.jpg"
+++

To configure specific compiler switches per package in Gentoo use these instructions.
<!--more-->

# Modifying environmental variables per package

The `package.env` file can be used to modify environmental variables per package. See [/etc/portage/env](http://wiki.gentoo.org/wiki//etc/portage/env) in the Gentoo Wiki for details.

# Conflicting compiler switches

In `make.conf` one typically specifies compiler switches that are selected to optimize for one's specific machine. But some packages (e.g. *www-client/chromium*) have their own build system, which can result in conflicting compiler switches.

# Disabling compiler switches per package

This can be done via `package.env` and helper files in the `env` subdirectory. For example, if `/etc/portage/make.conf` specifies the following section:

``` bash
CFLAGS="-O2 -march=native -pipe" CXXFLAGS="${CFLAGS}"
```

then in `/etc/portage/package.env` the following section will select specific flags for the `www-client/chromium` package:

``` bash
www-client/chromium cflags-no-optimization
```

and in the `/etc/portage/env/cflags-no-optimization` file holds the specific environmental variable:

``` bash
# No optimization # CFLAGS="-march=native -pipe"
CXXFLAGS="${CFLAGS}"
```

This prevents that the `-O2` compiler switch that is specified in `make.conf` is used for the `www-client/chromium` package.
