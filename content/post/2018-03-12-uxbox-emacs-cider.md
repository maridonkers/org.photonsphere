+++
author = "Mari Donkers"
title = "UXBOX source code browsing with Emacs+Cider"
date = "2018-03-12"
description = "The Clojure and ClojureScript application, which is impressive in its functionality and beautifully structured source code – UXBOX."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Internet",
    "Server",
    "Client",
    "Database",
    "GUI",
    "Clojure",
    "ClojureScript",
    "Docker",
    "IDE",
    "Editor",
    "Emacs",
]
categories = [
    "linux",
]
series = ["Clojure", "Editors"]
aliases = ["2018-03-12-uxbox-emacs-cider"]
thumbnail = "/images/emacs.svg"
+++

The [Clojure](http://clojure.org/) and [ClojureScript](http://clojurescript.org/) application, which is impressive in its functionality and beautifully structured source code – [UXBOX](https://github.com/uxbox/uxbox) (by **[uxbox.io](https://www.uxbox.io/)**).

Using Emacs+Cider for **UXBOX** source code browsing under **Linux**. To set up [Emacs](https://www.gnu.org/software/emacs/) for **Clojure** and **ClojureScript** with [Cider](https://github.com/clojure-emacs/cider), see e.g.: [My Emacs configuration](./2017-04-13-emacs-config.html).
<!--more-->

# Clone the UXBOX source code

In a subdirectory of your own choosing execute the following:

``` bash
git clone https://github.com/uxbox/uxbox.git
```

Which clones the UXBOX source code into a newly created `uxbox` subdirectory.

# Edit some UXBOX container files

We want to run emacs from inside the UXBOX Docker container (**beware of possible security implications –check your firewall)** and have its GUI displayed on the host's screen. To accomplish this some files need to be changed, as follows:

## `manage.sh`

Change the Docker run statement in `manage.sh` to the following:

``` bash
docker run --net=host -ti \
         -v `pwd`:/home/uxbox/uxbox  \
         -v $HOME/.m2:/home/uxbox/.m2 \
         -v $HOME/.gitconfig:/home/uxbox/.gitconfig \
         -v $HOME/.lein:/home/uxbox/.lein \
         -p 3449:3449 -p 6060:6060 -p 9090:9090 $IMGNAME:$REV
```

Which uses `--net=host` to use the host's network stack inside the container. Also maps (additionally) the `~/.lein` subdirectory. (The `-p 3449:3449 -p 6060:6060 -p 9090:9090` are now superfluous but I've left them in.)

## `docker/Dockerfile`

Change `docker/Dockerfile` to include Emacs stuff (unzip to view inside jars and the silver searcher):

``` bash
RUN apt-get update -yq &&  \
    apt-get install -yq bash git tmux vim openjdk-8-jdk rlwrap build-essential \
                        postgresql-9.6 postgresql-contrib-9.6 imagemagick webp \
                        sudo python unzip silversearcher-ag emacs
```

(The `python` package is included to prevent a `gulp` related error –it needs python somewhere.)

## `docker/files/start.sh`

Change `docker/files/start.sh` to comment out the `figwheel` line (we'll start it from Emacs):

``` bash
tmux new-window -t uxbox:1 -n 'figwheel'
tmux select-window -t uxbox:1
tmux send-keys -t uxbox 'cd uxbox/frontend' enter C-l
#tmux send-keys -t uxbox 'npm run figwheel' enter
```

## `frontend/scripts/figwheel.clj`

Change `options` so that the local backend is used.

``` clojure
(def options
  {;"uxbox.config.url" "https://demo.uxbox.io/api"
   "uxbox.config.url" "http://127.0.0.1:6060/api"
   })
```

Note the single semicolon `;` (a double semicolon `;;` results in an error during figwheel execution).

## `frontend/project.clj`

Change under `Build` to add piggieback.

``` clojure
;; Build
[com.cemerick/piggieback "0.2.2"]
[figwheel-sidecar "0.5.9" :scope "provided"]
[environ "1.1.0"]
```

And add nrepl options at the end, right above `:clean-targets`:

``` clojure
:repl-options {:nrepl-middleware [cemerick.piggieback/wrap-cljs-repl]}
:clean-targets ^{:protect false} ["resources/public/js" "target"]
```

# Build and run the Docker container

``` bash
./manage.sh build
```

If all went well with the build.

``` bash
./manage.sh run
```

This will take some time to initialize.

![](/images/UXBOX-started.png)

# In the backend tmux tab (Ctrl-b 2)

Start a headless REPL for the backend source code.

``` bash
lein trampoline repl :headless
```

![](/images/UXBOX-backend.png)

Jot down the port on which the nREPL server started.

# Create a new tmux tab (Ctrl-b c) to configure and run Emacs

Use `Ctrl-b c` to create a new tmux tab.

Set up your Emacs configuration with Cider.

I'm using my own config, as follows:

``` bash
git clone https://github.com/maridonkers/emacs-config.git /home/uxbox/.emacs.d
```

![](/images/UXBOX-emacs-config.png)

Setting up Emacs for source code browsing

First enable access for X-Windows (outside the Docker container):

``` bash
xhost +LOCAL:
```

Set the `DISPLAY` variable, start the Emacs daemon and edit the `backend/project.clj` and `frontend/project.clj` files in the `uxbox` subdirectory.

``` bash
export DISPLAY=:0
emacs --daemon
cd uxbox
emacsclient -nc backend/project.clj frontend/project.clj
```

![](/images/UXBOX-emacs-started.png)

(If `emacs --daemon` or `emacsclient` fails then re-run `emacs
--daemon` and try again.)

# Connect to backend REPL and start the backend

In your Emacs GUI switch to the `backend/project.clj` buffer and use `M-x cider-connect` to connect to the backend REPL. Normally you can use the default (localhost) and also press ENTER for the port number (which automatically finds the port number). If it doesn't work then use the jotted down backend REPL port number.

The backend REPL should now show up in a separate Emacs buffer. Now start the backend by typing `(start)` in the backend REPL buffer:

``` bash
(start)
```

![](/images/UXBOX-emacs-backend-repl.png)

# In the frontend tmux tab (Ctrl-b 1)

Start a headless REPL for the frontend source code.

``` bash
lein trampoline repl :headless
```

![](/images/UXBOX-frontend.png)

Jot down the port on which the nREPL server started.

# Connect to frontend REPL and start the frontend

In Emacs switch to the `frontend/project.clj` buffer and use `M-x
cider-connect` to connect to the frontend REPL. Normally you can use the default (localhost) and also press ENTER for the port number (which automatically finds the port number). If it doesn't work then use the jotted down frontend REPL port number.

The frontend REPL should now show up in a separate Emacs buffer. Now start the frontend by starting figwheel in the frontend REPL buffer:

``` clojure
(load-file "scripts/figwheel.clj")
```

![](/images/UXBOX-emacs-frontend-repl.png)

# Load or reload the page

The frontend REPL reports `Prompt will show when Figwheel connects to
your application`, which occurs when the page with the ClojureScript code is loaded or reloaded. So (re)load the <http://localhost:3449> page.

![](/images/UXBOX-browser-window.png)

Now the Figwheel prompt is shown.

![](/images/UXBOX-emacs-frontend-repl-activated.png)

# Browse the UXBOX source code

Now you're ready to browse through the UXBOX source code, using Emacs+Cider features (such as `cider-doc` to get documentation and `cider-find-var` to jump to a symbol).

![](/images/UXBOX-emacs-browsing-source-code.png)

(If Emacs+Cider features don't work right away then just throw in an `Ctrl+c+k` `cider-load-buffer` to kick it.)

# Manage repl connections

Sometimes you require a specific repl to be the active connection for a source file. E.g. for .cljc files. There is a section in the CIDER documentation on this: [Managing Connections](https://github.com/clojure-emacs/cider/blob/master/doc/managing_connections.md).
