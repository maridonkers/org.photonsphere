+++
author = "Mari Donkers"
title = "Make non-bootable ISO image for USB bootable"
date = "2014-12-16"
description = "Under Linux, you can use the isohybrid command to attempt to fix an ISO intended for a USB-stick, but that does not boot (because e.g. it expects a real DVD)."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "Shell Script",
]
categories = [
    "linux",
]
series = ["Linux"]
aliases = ["2014-12-16-make-non-bootable-iso-image-bootable"]
thumbnail = "images/linux.jpg"
+++

Under Linux, you can use the [isohybrid](http://www.syslinux.org/wiki/index.php/Isohybrid) command to attempt to fix an ISO intended for a USB-stick, but that does not boot (because e.g. it expects a real DVD).

(.more.)

Warning and disclaimer: do make sure that you make a copy of your image file first and execute the isohybrid command on the copy.

The command to use is as follows:

``` bash
isohybrid copy-of-your-image.iso
```

(Note: this requires syslinux to be installed.)
