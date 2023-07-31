+++
author = "Mari Donkers"
title = "Emacs editing in a Drupal Docker container"
date = "2019-09-06"
description = "Create a Drupal Docker image with support for Emacs editing set up (HTML, CSS, PHP files)."
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
    "Drupal",
]
categories = [
    "linux",
    "editor",
    "cms",
    "php",
]
series = ["Linux", "Docker", "Editors", "CMS", "PHP"]
aliases = ["2019-09-06-drupalcms-emacs."]
thumbnail = "/images/drupal.png"
+++

Create a [Drupal](https://www.drupal.org/) [Docker](https://www.docker.com/) image with support for [Emacs](https://www.gnu.org/software/emacs/) editing set up ([HTML](https://nl.wikipedia.org/wiki/HyperText_Markup_Language), [CSS](https://nl.wikipedia.org/wiki/Cascading_Style_Sheets), [PHP](http://www.php.net/) files). With [phpMyAdmin](https://www.phpmyadmin.net/) support. Under [Debian Linux](https://www.debian.org/) of course.

My [Emacs configuration](https://github.com/maridonkers/emacs-config) is used as an example to configure Emacs in the container.
<!--more-->

# Define the image via a Dockerfile

The `Dockerfile` (`Dockerfile-web`):

``` dockerfile
# Basic PHP container for Drupal PHP editing with Emacs.
#
# This Dockerfile is used from the Docker Compose file.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#
# Docker image: https://hub.docker.com/_/drupal/
#
# BEWARE: firewall must allow docker interface for 3306 (otherwise connection errors).
#       : use http://127.0.0.1:8081 to access Drupal GUI if localhost doesn't work;

FROM drupal

RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list

RUN apt-get update && apt-get install -yq procps iproute2 sudo git-core zip curl gnupg
RUN apt-get install -yq emacs25 vim silversearcher-ag

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN mkdir -p /opt/php
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/opt/php --filename=composer
RUN ln -s /opt/php/composer /usr/local/bin/composer

RUN sed -i "s#^\(www-data:.*:\)/usr/sbin/nologin#\1/bin/bash#" /etc/passwd
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# RUN usermod -u 1000 www-data
# RUN usermod -G staff www-data
RUN chown www-data /var/www
WORKDIR /var/www

ENV DISPLAY=:0
```

# The Docker compose file

``` dockerfile
# Basic PHP container for Drupal PHP editing with Emacs.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#
# Docker image: https://hub.docker.com/_/drupal/

version: '3'
services:
  web:
    # image: drupal
    build: 
      context: .
      dockerfile: Dockerfile-web
    environment:
       DISPLAY:
    network_mode: host
    # ports:
    #   - "8000:80"
    stdin_open: true
    tty: true
  db:
    image: mysql:5.7
    # volumes:
      # - ./db-backups:/var/mysql/backups:delegated
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: drupal1
      MYSQL_USER: drupal1
      MYSQL_PASSWORD: drupal1
    networks:
      - back
    ports:
      - "3306:3306"
  pma:
    image: phpmyadmin/phpmyadmin
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: root
      PHP_UPLOAD_MAX_FILESIZE: 1G
      PHP_MAX_INPUT_VARS: 1G
    networks:
      - back
    ports:
     - "8001:80"

networks:
  back:
```

# Compose up

To build images and bring them up.

``` bash
$ docker-compose up --build -d
Creating network "drupal1_default" with the default driver
Building web
Step 1/9 : FROM drupal
 ---> c362e86c8769
Step 2/9 : RUN sed -i "s#\smain\s*\$# main contrib non-free#" /etc/apt/sources.list
 ---> Using cache
 ---> 5624e4872798
Step 3/9 : RUN apt-get update && apt-get install -yq procps iproute2 sudo git-core zip curl gnupg
 ---> Using cache
 ---> 69d38cb8e0f2
Step 4/9 : RUN apt-get install -yq emacs25 vim silversearcher-ag
 ---> Using cache
 ---> 64b319596a11
Step 5/9 : RUN sed -i "s#^\(www-data:.*:\)/usr/sbin/nologin#\1/bin/bash#" /etc/passwd
 ---> Using cache
 ---> 24a125040132
Step 6/9 : RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
 ---> Using cache
 ---> 9ee3dddfffdb
Step 7/9 : RUN chown www-data /var/www
 ---> Using cache
 ---> 10062f436b3c
Step 8/9 : WORKDIR /var/www
 ---> Using cache
 ---> 73e32a4bb1f9
Step 9/9 : ENV DISPLAY=:0
 ---> Using cache
 ---> 0757563ba445
Successfully built 0757563ba445
Successfully tagged drupal1_web:latest
Creating drupal1_pma_1 ... done
Creating drupal1_web_1 ... done
Creating drupal1_db_1  ... done
```

Visit <http://localhost:80> for the Drupal site. Visit <http://localhost:8001> for the phpMyAdmin interface.

# MySQL configuration

In the Drupal configuration screen use host `127.0.0.1` with port `3306` (plain `localhost` will not work).

# Connect to development image

First enable access for X-Windows:

``` bash
xhost +LOCAL:
```

Execute a bash shell in the container and set up Emacs.

``` bash
$ docker exec -ti drupal1_web_1 /bin/bash
```

From the bash shell in the container:

``` bash
# su - www-data

www-data$ git clone https://github.com/maridonkers/emacs-config.git /var/www/.emacs.d
Cloning into '/var/www/.emacs.d'...
remote: Enumerating objects: 114, done.
remote: Counting objects: 100% (114/114), done.
remote: Compressing objects: 100% (80/80), done.
remote: Total 545 (delta 68), reused 79 (delta 34), pack-reused 431
Receiving objects: 100% (545/545), 136.94 KiB | 0 bytes/s, done.
Resolving deltas: 100% (316/316), done.

www-data$ emacs --daemon
...
Loading /var/www/.emacs.d/loader.el (source)...done
Loaded /var/www/.emacs.d/loader.el
No desktop file.
Saving file /var/www/.emacs.d/init.el...
Wrote /var/www/.emacs.d/init.el
Wrote /var/www/.emacs.d/init.el
Starting Emacs daemon.

www-data$ emacsclient -nc html/index.php
```

If the emacsclient command doesn't work the first time then restart the Emacs daemon by repeating the `emacs --daemon` and `emacsclient
-nc html/index.php` commands.

# Emacs running

![](/images/drupalcms-emacs.png)
