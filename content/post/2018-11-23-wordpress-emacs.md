+++
author = "Mari Donkers"
title = "Emacs editing in a Wordpress Docker container"
date = "2018-11-23"
description = "Create a Wordpress Docker image with Emacs editing set up (HTML, CSS, PHP files). With phpMyAdmin support."
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
thumbnail = "/images/wordpress.png"
+++

Create a [Wordpress](https://wordpress.org/) [Docker](https://www.docker.com/) image with [Emacs](https://www.gnu.org/software/emacs/) editing set up ([HTML](https://nl.wikipedia.org/wiki/HyperText_Markup_Language), [CSS](https://nl.wikipedia.org/wiki/Cascading_Style_Sheets), [PHP](http://www.php.net/) files). With [phpMyAdmin](https://www.phpmyadmin.net/) support. Under [Debian Linux](https://www.debian.org/) of course.

My [Emacs configuration](https://github.com/maridonkers/emacs-config) is used as an example to configure Emacs in the container.
<!--more-->

# Define the image via a Dockerfile

The `Dockerfile`:

``` dockerfile
# Basic PHP container for PHP editing with Emacs.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#
# Use a .gitignore, e.g. https://salferrarello.com/wordpress-gitignore/

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
# Basic PHP container for Wordpress PHP editing with Emacs.
#
# Twitter: @maridonkers | Google+: +MariDonkers | GitHub: maridonkers.
#
# BEWARE: firewall must allow docker interface for 3306 (otherwise connection errors);
#       : use http://127.0.0.1:8080 to access Wordpress GUI if localhost doesn't work.

version: '2'
services:
  db:
     image: mysql:5.7
     volumes:
       - db:/var/lib/mysql
     restart: unless-stopped
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress
     networks:
       - back

  phpmyadmin:
     depends_on:
       - db
     image: phpmyadmin/phpmyadmin
     restart: unless-stopped
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress
       PMA_USER: wordpress
       PMA_PASSWORD: wordpress
       PMA_ARBITRARY: 1
     networks:
       - back
     ports:
       - 8090:80

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    restart: unless-stopped
    volumes:
       - www:/var/www
       - html:/var/www/html
    environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress
    networks:
       - back
    ports:
       - 8080:80

  development:
    depends_on:
      - wordpress
    # restart: always
    image: wordpress-development
    build: .
    environment:
       DISPLAY:
    volumes:
       - www:/var/www
       - html:/var/www/html
    network_mode: host
    stdin_open: true
    tty: true

networks:
  back:

volumes:
  db:
  www:
  html:
```

# Compose up

To build images and bring them up.

``` bash
$ docker-compose up -d
Creating network "wordpress_back" with the default driver
Creating volume "wordpress_www" with default driver
Creating volume "wordpress_html" with default driver
Creating volume "wordpress_db" with default driver
Creating wordpress_db_1
Creating wordpress_phpmyadmin_1
Creating wordpress_wordpress_1
Creating wordpress_development_1
```

Visit <http://127.0.0.1:8080> for the Wordpress front end and <http://127.0.0.1:8080/wp-admin> for the backend. Visit <http://localhost:8090> for the phpMyAdmin interface.

# Connect to development image

First enable access for X-Windows:

``` bash
xhost +LOCAL:
```

Attach to a bash shell in the container and set up Emacs.

``` bash
$ docker attach wordpress_wordpress-development_1
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

www-data$ emacsclient -nc html/index.php 
```

If the emacsclient command doesn't work the first time then restart the Emacs daemon by repeating the `emacs --daemon` and `emacsclient
-nc html/index.php` commands.

# Emacs running

![](/images/wordpress-emacs.png)
