+++
author = "Mari Donkers"
title = "Emacs editing in an October CMS Docker container"
date = "2018-11-22"
description = "Create an October CMS Docker image with support for Emacs editing set up (HTML, CSS, PHP files). With phpMyAdmin support."
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "Server",
    "Client",
    "PHP",
    "CMS",
    "GUI",
    "Docker",
    "Editor",
    "Emacs",
]
categories = [
    "linux",
    "editor",
    "cms",
    "php",
]
series = ["Linux", "Docker", "Editors", "CMS", "PHP"]
aliases = ["2018-11-22-octobercms-emacs"]
thumbnail = "/images/php.svg"
+++

Create an [October CMS](https://octobercms.com) [Docker](https://www.docker.com/) image with support for [Emacs](https://www.gnu.org/software/emacs/) editing set up ([HTML](https://nl.wikipedia.org/wiki/HyperText_Markup_Language), [CSS](https://nl.wikipedia.org/wiki/Cascading_Style_Sheets), [PHP](http://www.php.net/) files). With [phpMyAdmin](https://www.phpmyadmin.net/) support. Under [Debian Linux](https://www.debian.org/) of course.

My [Emacs configuration](https://github.com/maridonkers/emacs-config) is used as an example to configure Emacs in the container.
<!--more-->

# Define the image via a Dockerfile

The `Dockerfile`:

``` dockerfile
# Basic PHP container for PHP editing with Emacs.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#

FROM debian

RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list

RUN apt-get update && apt-get install -yq procps sudo git-core zip curl gnupg
RUN apt-get install -yq emacs25 vim silversearcher-ag

# Repository for newer PHP versions (Debian Stretch has 7.0 but e.g. phpactor requires >=7.1).
# https://tecadmin.net/install-php-debian-9-stretch/
RUN apt-get install -yq ca-certificates apt-transport-https
RUN curl -sS https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php/ stretch main" >> /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get install -yq php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN mkdir -p /opt/php
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/opt/php --filename=composer
RUN ln -s /opt/php/composer /usr/local/bin/composer

WORKDIR /opt/php
RUN curl -LO https://github.com/phpstan/phpstan/releases/download/0.10.5/phpstan.phar
RUN chmod +x phpstan.phar
RUN ln -s /opt/php/phpstan.phar /usr/local/bin/phpstan

WORKDIR /opt/php
RUN curl -LO https://psysh.org/psysh
RUN chmod +x psysh
RUN ln -s /opt/php/psysh /usr/local/bin/psysh

RUN sed -i "s#^\(www-data:.*:\)/usr/sbin/nologin#\1/bin/bash#" /etc/passwd
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /var/www

ENV DISPLAY=:0
ENTRYPOINT ["/bin/bash"]
```

# The Docker compose file

``` dockerfile
# Basic PHP container for October CMS PHP editing with Emacs.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#
# Docker image: https://hub.docker.com/r/aspendigital/octobercms/
#
# BEWARE: firewall must allow docker interface for 3306 (otherwise connection errors).
#       : use http://127.0.0.1:8081 to access October CMS GUI if localhost doesn't work;
#       : To seed database use docker-compose exec web php artisan october:up

version: '2'

services:
  db:
    image: mysql:5.7
    restart: unless-stopped
    volumes:
      - db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: octobercms
    networks:
      - back
    ports:
      - 3306:3306

  phpmyadmin:
     depends_on:
       - db
     image: phpmyadmin/phpmyadmin
     restart: unless-stopped
     environment:
       MYSQL_ROOT_PASSWORD: root
       MYSQL_USER: root
       MYSQL_PASSWORD: root
       PMA_USER: root
       PMA_PASSWORD: root
       PMA_ARBITRARY: 1
     networks:
       - back
     ports:
       - 8091:80

  octobercms:
    depends_on:
       - db
    image: aspendigital/octobercms
    restart: unless-stopped
    volumes:
       - www:/var/www
    environment:
       DB_TYPE: mysql
       DB_HOST: db #DB_HOST should match the service name of the database container
       DB_DATABASE: octobercms
       DB_USERNAME: root
       DB_PASSWORD: root
    networks:
      - back
    ports:
      - 8081:80

  octobercms-development:
    depends_on:
      - octobercms
    image: octobercms-development
    build: .
    volumes:
      - www:/var/www
    environment:
       DISPLAY:
    network_mode: host
    stdin_open: true
    tty: true

networks:
  back:

volumes:
  db:
  www:
```

# Compose up

To build images and bring them up.

``` bash
$ docker-compose up -d
Creating network "octobercms_back" with the default driver
Creating volume "octobercms_www" with default driver
Creating volume "octobercms_db" with default driver
Creating octobercms_db_1
Creating octobercms_octobercms_1
Creating octobercms_phpmyadmin_1
Creating octobercms_octobercms-development_1
```

Initialize and seed database:

``` bash
$ docker-compose exec octobercms php artisan october:up
Migrating application and plugins...
Migration table created
System
 - Migrating: 2013_10_01_000001_Db_Deferred_Bindings
 - Migrated:  2013_10_01_000001_Db_Deferred_Bindings
 - Migrating: 2013_10_01_000002_Db_System_Files
 - Migrated:  2013_10_01_000002_Db_System_Files
 - Migrating: 2013_10_01_000003_Db_System_Plugin_Versions
 - Migrated:  2013_10_01_000003_Db_System_Plugin_Versions
 - Migrating: 2013_10_01_000004_Db_System_Plugin_History
 - Migrated:  2013_10_01_000004_Db_System_Plugin_History
 - Migrating: 2013_10_01_000005_Db_System_Settings
 - Migrated:  2013_10_01_000005_Db_System_Settings
 - Migrating: 2013_10_01_000006_Db_System_Parameters
 - Migrated:  2013_10_01_000006_Db_System_Parameters
 - Migrating: 2013_10_01_000007_Db_System_Add_Disabled_Flag
 - Migrated:  2013_10_01_000007_Db_System_Add_Disabled_Flag
 - Migrating: 2013_10_01_000008_Db_System_Mail_Templates
 - Migrated:  2013_10_01_000008_Db_System_Mail_Templates
 - Migrating: 2013_10_01_000009_Db_System_Mail_Layouts
 - Migrated:  2013_10_01_000009_Db_System_Mail_Layouts
 - Migrating: 2014_10_01_000010_Db_Jobs
 - Migrated:  2014_10_01_000010_Db_Jobs
 - Migrating: 2014_10_01_000011_Db_System_Event_Logs
 - Migrated:  2014_10_01_000011_Db_System_Event_Logs
 - Migrating: 2014_10_01_000012_Db_System_Request_Logs
 - Migrated:  2014_10_01_000012_Db_System_Request_Logs
 - Migrating: 2014_10_01_000013_Db_System_Sessions
 - Migrated:  2014_10_01_000013_Db_System_Sessions
 - Migrating: 2015_10_01_000014_Db_System_Mail_Layout_Rename
 - Migrated:  2015_10_01_000014_Db_System_Mail_Layout_Rename
 - Migrating: 2015_10_01_000015_Db_System_Add_Frozen_Flag
 - Migrated:  2015_10_01_000015_Db_System_Add_Frozen_Flag
 - Migrating: 2015_10_01_000016_Db_Cache
 - Migrated:  2015_10_01_000016_Db_Cache
 - Migrating: 2015_10_01_000017_Db_System_Revisions
 - Migrated:  2015_10_01_000017_Db_System_Revisions
 - Migrating: 2015_10_01_000018_Db_FailedJobs
 - Migrated:  2015_10_01_000018_Db_FailedJobs
 - Migrating: 2016_10_01_000019_Db_System_Plugin_History_Detail_Text
 - Migrated:  2016_10_01_000019_Db_System_Plugin_History_Detail_Text
 - Migrating: 2016_10_01_000020_Db_System_Timestamp_Fix
 - Migrated:  2016_10_01_000020_Db_System_Timestamp_Fix
 - Migrating: 2017_08_04_121309_Db_Deferred_Bindings_Add_Index_Session
 - Migrated:  2017_08_04_121309_Db_Deferred_Bindings_Add_Index_Session
 - Migrating: 2017_10_01_000021_Db_System_Sessions_Update
 - Migrated:  2017_10_01_000021_Db_System_Sessions_Update
 - Migrating: 2017_10_01_000022_Db_Jobs_FailedJobs_Update
 - Migrated:  2017_10_01_000022_Db_Jobs_FailedJobs_Update
 - Migrating: 2017_10_01_000023_Db_System_Mail_Partials
 - Migrated:  2017_10_01_000023_Db_System_Mail_Partials
 - Migrating: 2017_10_23_000024_Db_System_Mail_Layouts_Add_Options_Field
 - Migrated:  2017_10_23_000024_Db_System_Mail_Layouts_Add_Options_Field
Backend
 - Migrating: 2013_10_01_000001_Db_Backend_Users
 - Migrated:  2013_10_01_000001_Db_Backend_Users
 - Migrating: 2013_10_01_000002_Db_Backend_User_Groups
 - Migrated:  2013_10_01_000002_Db_Backend_User_Groups
 - Migrating: 2013_10_01_000003_Db_Backend_Users_Groups
 - Migrated:  2013_10_01_000003_Db_Backend_Users_Groups
 - Migrating: 2013_10_01_000004_Db_Backend_User_Throttle
 - Migrated:  2013_10_01_000004_Db_Backend_User_Throttle
 - Migrating: 2014_01_04_000005_Db_Backend_User_Preferences
 - Migrated:  2014_01_04_000005_Db_Backend_User_Preferences
 - Migrating: 2014_10_01_000006_Db_Backend_Access_Log
 - Migrated:  2014_10_01_000006_Db_Backend_Access_Log
 - Migrating: 2014_10_01_000007_Db_Backend_Add_Description_Field
 - Migrated:  2014_10_01_000007_Db_Backend_Add_Description_Field
 - Migrating: 2015_10_01_000008_Db_Backend_Add_Superuser_Flag
 - Migrated:  2015_10_01_000008_Db_Backend_Add_Superuser_Flag
 - Migrating: 2016_10_01_000009_Db_Backend_Timestamp_Fix
 - Migrated:  2016_10_01_000009_Db_Backend_Timestamp_Fix
 - Migrating: 2017_10_01_000010_Db_Backend_User_Roles
 - Migrated:  2017_10_01_000010_Db_Backend_User_Roles
Cms
 - Migrating: 2014_10_01_000001_Db_Cms_Theme_Data
 - Migrated:  2014_10_01_000001_Db_Cms_Theme_Data
 - Migrating: 2016_10_01_000002_Db_Cms_Timestamp_Fix
 - Migrated:  2016_10_01_000002_Db_Cms_Timestamp_Fix
 - Migrating: 2017_10_01_000003_Db_Cms_Theme_Logs
 - Migrated:  2017_10_01_000003_Db_Cms_Theme_Logs
October.Demo
- v1.0.1:  First version of Demo
October.Drivers
- v1.0.1:  First version of Drivers
- v1.0.2:  Update Guzzle library to version 5.0
- v1.1.0:  Update AWS library to version 3.0
- v1.1.1:  Update Guzzle library to version 6.0
- v1.1.2:  Update Guzzle library to version 6.3
Seeded System 
Seeded Backend
```

Visit <http://localhost:8081> for the October CMS front end and <http://localhost:8081/backend> for the backend. Visit <http://localhost:8091> for the phpMyAdmin interface.

# Connect to development image

First enable access for X-Windows:

``` bash
xhost +LOCAL:
```

Attach to a bash shell in the container and set up Emacs.

``` bash
$ docker attach octobercms_octobercms-development_1
```

From the bash shell in the container:

``` bash
# chown www-data /var/www
# su - www-data
www-data$ git clone https://github.com/maridonkers/emacs-config.git /var/www/.emacs.d
www-data$ emacs --daemon

Warning: due to a long standing Gtk+ bug
http://bugzilla.gnome.org/show_bug.cgi?id=85715
Emacs might crash when run in daemon mode and the X11 connection is unexpectedly lost.
Using an Emacs configured with --with-x-toolkit=lucid does not have this problem.
Loading 00debian-vars...
Loading 00debian-vars...done
Loading /etc/emacs/site-start.d/50autoconf.el (source)...
Loading /etc/emacs/site-start.d/50autoconf.el (source)...done
Loading /var/www/.emacs.d/loader.el (source)...
Lets install some packages
running packages-install
[yas] Prepared just-in-time loading of snippets (but no snippets found).
[yas] Prepared just-in-time loading of snippets successfully.
Loading /var/www/.emacs.d/loader.el (source)...done
Loaded /var/www/.emacs.d/loader.el
Wrote /var/www/.emacs.d/.emacs.desktop.lock
Desktop: 2 frames, 19 buffers restored.
Starting Emacs daemon.

www-data$ emacsclient -nc html/server.php 
```

If the emacsclient command doesn't work the first time then restart the Emacs daemon by repeating the `emacs --daemon` and `emacsclient
-nc html/server.php` commands.

# Emacs running

![](/images/octobercms-emacs.png)
