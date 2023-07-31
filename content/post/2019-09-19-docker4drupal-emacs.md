+++
author = "Mari Donkers"
title = "Emacs editing in a Docker4Drupal container"
date = "2019-09-11"
description = "Create a Docker4Drupal image with support for Emacs editing set up (HTML, CSS, PHP files). Drupal4Docker has Portainer support."
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

Create a [Docker4Drupal](https://github.com/wodby/docker4drupal) image with support for [Emacs](https://www.gnu.org/software/emacs/) editing set up ([HTML](https://nl.wikipedia.org/wiki/HyperText_Markup_Language), [CSS](https://nl.wikipedia.org/wiki/Cascading_Style_Sheets), [PHP](http://www.php.net/) files). Drupal4Docker has [Portainer](https://www.portainer.io/) support.

My [Emacs configuration](https://github.com/maridonkers/emacs-config) is used as an example to configure Emacs in the container.
<!--more-->

# Docker4Drupal

Initially follow instructions at [Local environment with Docker4Drupal](https://wodby.com/docker4drupal).

# Add GUI support

Add GUI support to the Docker compose file by adding two lines to the `volumes` under `nginx`, below the existing line `- ./:/var/www/html`, as follows:

``` dockerfile
volumes:
 - ./:/var/www/html
 - /tmp/.X11-unix/:/tmp/.X11-unix/:ro
 - ~/.Xauthority:/home/wodby/.Xauthority:rw
```

This is inspired by the following YouTube video: [How to Run a Graphical Application from a Container? Yes, I Know IT! Ep 20](https://youtu.be/Jp58Osb1uFo).

# Compose up

To build images and bring them up.

``` bash
$ docker-compose up -d --build
```

Allow for some time to let it settle.

Visit <http://drupal.docker.localhost:8000/> for your site. Visit [<http://portainer.aboveurl/>](http://portainer.drupal.docker.localhost:8000/) for the Portainer interface.

# Connect to development image

Execute a root bash shell in the container to install required additional packages.

``` bash
$ docker exec -u 0 -ti my_drupal8_project_nginx /bin/bash

bash-4.4# 
```

From the root bash shell in the container:

``` bash
bash-4.4# apk add git emacs-x11 the_silver_searcher ttf-dejavu
...

bash-4.4# exit
```

Execute a bash shell in the container to set up Emacs.

``` bash
$ docker exec -ti my_drupal8_project_nginx /bin/bash
/var/www/html$ 
```

From the bash shell in the container:

``` bash
/var/www/html$ git clone https://github.com/maridonkers/emacs-config.git ~/.emacs.d
...

/var/www/html$ export DISPLAY=:0

/var/www/html$ emacs --daemon
...

/var/www/html$ emacsclient -nc web/index.php
```

If the emacsclient command doesn't work the first time then restart the Emacs daemon by repeating the `emacs --daemon` and `emacsclient
-nc web/index.php` commands.

# Emacs running

![](/images/drupal4docker-emacs.png)
