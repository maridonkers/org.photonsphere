+++
author = "Mari Donkers"
title = "(Gentoo) Linux low-level backup"
date = "2014-12-30"
description = "If a low-level backup is required then use these instructions."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "Gentoo",
    "Shell Script",
]
categories = [
    "linux",
]
series = ["Linux"]
aliases = ["2014-12-30-gentoo-linux-low-level-backup"]
thumbnail = "images/linux.jpg"
+++

If a low-level backup is required then use these instructions.
<!--more-->

# Rolling release

If your Linux distribution has a rolling release model (e.g. [Gentoo Linux](http://www.gentoo.org/)) then you'll probably have to install it only once. With a non-rolling release distribution you'll have to do a system upgrade every now and then. Either way, the OS installed on your hard disk will remain there for quite a long time and backing it up may prove useful.

# Partition table backup

The following post describes how this can be done for various partitioning technologies (DOS-type MBR, GPT and LVM): [How to backup DOS-type partition table/GPT and LVM metadata?](https://blog.sleeplessbeastie.eu/2012/05/14/how-to-backup-dos-type-partition-table-gpt-and-lvm-metadata/)

# Partitioning scheme

If you have separate partitions for user data (typically /home) then the OS will be in one or more separate partitions, cleanly separated from user data and therefore easier to back up. For background information on this, see the [Gentoo Linux Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page), specifically the section on preparing disks (e.g. [Handbook:AMD64/Installation/Disks](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks)).

The `lsblk -l` command can be used to list partitions and their mount points on your system.

# OS Partitions backup

To back up an OS partition it must not be in use (i.e. mounted). So it's necessary to boot from a separate medium (e.g. the [2014 Gentoo Live DVD](http://www.gentoo.org/news/20140826-livedvd.xml), which can also be used to create a [LiveUSB](https://wiki.gentoo.org/wiki/LiveUSB/HOWTO)).

When booted from the Live DVD you can use the `fdisk -l` command to list partitions.

To back up an OS partition you'll have to mount the OS partition (a read-only mount can be used) and the target medium where you want to store the backup. Be very careful to use the correct partitions, make sure there's enough space on the target medium, etc. If you do not know what you're doing, not familiar with Linux system administration and the [mount command](http://wiki.gentoo.org/wiki/Mount) then do not attempt this.

Once the OS partition to back up is mounted on e.g. `/mnt/source` (read-only mount suffices) and the destination medium is mounted on e.g. `/mnt/destination` (writable mount is required) then e.g. the following command can be used to back up the whole OS partition's file system:

``` bash
cd /mnt/destination/somepath/backupname ( cd /mnt/source ; tar cf - . ) | tar xvf -
```

The `verbose` flag in the unpacking `tar` command can be omitted if visual feedback of progress is not required.

In backupname it's wise to include the partition type (e.g. ext2, ext3, ext4, xfs, etc.) and the partition label (i.e. its name). This makes it easier to restore the partition later.

When done use the following to cleanly unmount the mounted partitions:

``` bash
cd / umount /destination umount /source
```

Repeat for all the OS partitions (except those not containing a regular file system, such as the SWAP partition).

# Restore of partition table and OS partitions

This should be done only as a last resort. Be very careful because e.g. restoring to the wrong partition will destroy your data, very likely beyond repair. Before attempting this make absolutely sure that all data on media that are attached to the system are properly backed up!

Also read the `Restored system does` not boot section the end of this article.

As a first step boot from a separate medium (e.g. the [2014 Gentoo Live DVD](http://www.gentoo.org/news/20140826-livedvd.xml), which can also be used to create a [LiveUSB](https://wiki.gentoo.org/wiki/LiveUSB/HOWTO)).

To restore the partition table read the `Partition table backup` section (the referred post also contains information about restore options).

To restore OS partitions first create the file system of the proper type and label (both of which were included in the name of the backup). Depending on the partition type e.g. use **one** of the following commands:

``` bash
mkfs.ext2 -L thelabel
mkfs.ext3 -L thelabel
mkfs.ext4 -L thelabel
mkfs.xfs -L thelabel
```

Next mount the file system that was just created (e.g. on `/mnt/destination`) and the medium that contains the backup (the latter is now the source medium and can be mounted read-only, e.g. on `/mnt/source`.

The following command can now be used to restore the OS partition's file system:

``` bash
cd /mnt/destination ( cd /mnt/source/somepath/backupname ; tar cf - . ) | tar xvf -
```

When done use the following to cleanly unmount the mounted partitions:

``` bash
cd / umount /destination umount /source
```

# Restored system does not boot

The restored system will probably not boot because the bootloader was not backed up and restored. Bootloaders are e.g. stored in free sectors between the partition table and the first data sector on your disk.

To boot the system you'll have to e.g. re-install your boot loader when booted from an separate medium (e.g. the [2014 Gentoo Live DVD](http://www.gentoo.org/news/20140826-livedvd.xml), which can also be used to create a [LiveUSB](https://wiki.gentoo.org/wiki/LiveUSB/HOWTO)).

For background information on the bootloader, see the [Gentoo Linux Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page), specifically the section on configuring the bootloader (e.g. [Handbook:AMD64/Installation/Bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader)).
