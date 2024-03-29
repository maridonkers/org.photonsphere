+++
title = "Hardware"
description = "The Photon Sphere - where light travels in circles."
date = "2023-07-30"
aliases = ["hardware"]
author = "Mari Donkers"
+++

A summary of my computer hardware is given here.

# Computer

## ASUS N53Jn notebook (8GiB)

The [ASUS N53Jn](https://tweakers.net/pricewatch/270517/asus-asus-n53jn/specificaties/) installed with [NixOS](https://nixos.org/) (Linux) is my daily driver. The optical drive has been replaced with a hard drive caddy.

![](/images/AsusN53Jn.jpg)

`lscpu`

``` example
CPU(s):                  4
Vendor ID:               GenuineIntel
  Model name:            Intel(R) Core(TM) i5 CPU       M 450  @ 2.40GHz
    Thread(s) per core:  2
    Core(s) per socket:  2
```

`lsscsi`

``` example
[0:0:0:0]    disk    ATA      WDC WD5000BEKT-6 1A01  /dev/sdb 
[1:0:0:0]    disk    ATA      ST1000LM048-2E71 SDM1  /dev/sda 
```

## HP Compaq DC7900 Ultra-slim Desktop PC (4GiB)

I use the [HP Compaq DC7900 Ultra-slim Desktop PC](https://icecat.biz/p/hp/kp722av/pcs-workstations-Compaq+dc7900+Base+Model+Ultra-slim+Desktop+PC-1748699.html) installed with [NixOS](https://nixos.org/) (Linux) only sometimes (e.g. for burning CDs; server deployment tests).

![](/images/HPCompaqDC7900.jpg)

`lscpu`

``` example
CPU(s):                  2
Vendor ID:               GenuineIntel
  Model name:            Intel(R) Core(TM)2 Duo CPU     E8400  @ 3.00GHz
    Thread(s) per core:  1
    Core(s) per socket:  2
```

`lsscsi`

``` example
[2:0:0:0]    disk    ATA      ST9160412AS      HPM1  /dev/sda 
[3:0:0:0]    cd/dvd  hp       DVD A  DS8A3L    YH3B  /dev/sr0 
```


# Peripherals

## Iiyama ProLite E2407HDS monitor

The [E2407HDS](https://tweakers.net/pricewatch/230667/iiyama-prolite-e2407hds-1-zwart/specificaties/) monitor is primarily connected to my development notebook via HDMI (can switch to VGA input for my other computer).

![](/images/IiyamaProliteE2407HDS.jpg)

## Mouse, Keyboard

Both from Logitech.

![](/images/MouseKeyboard.jpg)

## Printer

The [M1217nfw](https://tweakers.net/pricewatch/284973/hp-laserjet-pro-m1217nfw-ce844a/specificaties/) printer is connected to my development laptop via a USB-cable (until I have time to reconfigure its WiFi-password, which I had to change because I accidentely published my full `NixOS` configuration on GitHub).

![](/images/HPLaserjetM1217nfwMFP.jpg)
