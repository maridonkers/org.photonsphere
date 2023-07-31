+++
author = "Mari Donkers"
title = "Fulcro development with Emacs+Cider"
date = "2017-12-19"
description = "Using Emacs+Cider for development with Fulcro. To set up Emacs for Clojure and ClojureScript development with Cider."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Server",
    "Clojure",
    "ClojureScript",
    "Editor",
    "Emacs",
    "Full Stack",
]
categories = [
    "clojure",
    "editor",
    "full stack",
]
series = ["Clojure", "Editors", "Full Stack"]
aliases = ["2017-12-19-fulcro-emacs-cider"]
thumbnail = "/images/emacs.svg"
+++

Using Emacs+Cider for development with [Fulcro](http://fulcro.fulcrologic.com/). To set up Emacs for [Clojure](http://clojure.org/) and [ClojureScript](http://clojurescript.org/) development with Cider see e.g.: [My Emacs configuration](./2017-04-13-emacs-config.html)
<!--more-->

# Start headless REPL

Start a headless REPL.

``` bash
JVM_OPTS="-Ddev" lein repl :headless
```

Jot down the port on which the nREPL server started.

# Connect to REPL (for Clojure)

In Emacs use `M-x cider-connect` to connect to the REPL. Normally you can use the default (localhost) and also press ENTER for the port number (which automatically finds the port number). If it doesn't work then use the jotted down port number.

# Start the server in the Clojure REPL

``` clojure
(go)
```

# Create a second connection to the REPL (for ClojureScript)

In Emacs use `M-x cider-connect` to again connect to the REPL. On the question `REPL buffer already exists (*cider-repl localhost*). Do you
really want to create a new one? (y or n)` answer y.

# Initialize the ClojureScript REPL

In the ClojureScript REPL type the following command:

``` clojure
(start-figwheel)
```

# Load or reload the page

The ClojureScript REPL reports `Prompt will show when Figwheel
connects to your application`, which occurs when the page with the ClojureScript code is loaded or reloaded.

# Get initial- and current state

Sidetracking, on how to get initial- and current state in the [Fulcro template project](https://github.com/fulcrologic/fulcro-template).

To see the initial state, use the following from a cljs repl:

``` clojure
(fulcro.client.primitives/get-initial-state fulcro-template.ui.root/Root {})
```

To see the current state, use the following from a cljs repl:

``` clojure
@(fulcro.client.primitives/app-state (get @fulcro-template.client/app :reconciler))
```

# Manage repl connections

Sometimes you require a specific repl to be the active connection for a source file. E.g. for .cljc files. There is a section in the CIDER documentation on this: [Managing Connections](https://github.com/clojure-emacs/cider/blob/master/doc/managing_connections.md).

# Screendump with Fulcro template project

![](/images/fulcro-template.png)
