+++
author = "Mari Donkers"
title = "Building Photivo under Debian Linux"
date = "2015-01-30"
description = ""
featured = false
tags = [
    "Computer",
    "Software",
    "Shell Script",
    "GUI",
]
categories = [
    "linux",
    "photography",
]
series = ["Linux"]
aliases = ["2015-01-30-building-photivo-under-debian-linux "]
thumbnail = "/images/camera.jpg"
+++

[Photivo](http://photivo.org/) is a free and open source (GPL3) photo processor. It handles your RAW files as well as your bitmap files (TIFF, JPEG, BMP, PNG and many more) in a non-destructive 16 bit processing pipe with gimp workflow integration and batch mode.

# Linux build instructions

The instructions to build Photivo under Linux can be found on the Photivo site, under [Photivo -\> Download and Setup -\> Linux](http://photivo.org/download/linux).

The Debian Linux (Jessie) specific parts of these instructions are given in the following sections.

# Packages

The command to install the required packages for Debian is as follows:

``` bash
sudo apt-get install gcc g++ ccache qt4-qmake mercurial libqt4-dev libjpeg62-turbo-dev:amd64 libexiv2-dev liblensfun-dev libfftw3-dev libpng12-dev libtiff5 liblcms2-dev libgimp2.0-dev libgraphicsmagick++3
```

# Lcms2

On my system the Debian package for `lcms2` works fine. This was installed already (above under the `Packages` section).

# GraphicsMagick 16 bit

This needs to be downloaded and built as instructed. But do change the prefix to `/usr/local`, so the commands to use are as follows:

``` bash
./configure --prefix=/usr/local --with-quantum-depth=16 --enable-shared --without-lcms
make -j4
sudo make install

```

# Liquid rescale (liblqr)

This needs to be downloaded and built as instructed. But do change the prefix to `/usr/local`, so the commands to use are as follows:

``` bash
./configure --prefix=/usr/local
 make -j4
 sudo make install
```

# Lensfun header files

Because the =lensfun- header files are located in a different location than expected by Photivo an environment variable needs to be set as follows:

``` bash
INCLUDEPATHS="/usr/include/lensfun"
export INCLUDEPATHS
```

# Building Photivo

With the `INCLUDEPATHS` environment variable set as instructed above the instructions for building Photivo can be followed. But do change the prefix to `/usr/local`, so the commands to use are as follows:

``` bash
hg clone https://photivo.googlecode.com/hg/ photivo
cd photivo
hg update default
qmake photivo.pro PREFIX=/usr/local
make -j4
sudo make install
```
