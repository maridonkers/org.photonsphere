+++
author = "Mari Donkers"
title = "Cryogen static site generator"
date = "2017-02-11"
description = "Cryogen is a simple static site generator built with Clojure"
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Internet",
    "HTML",
    "CSS",
    "Web",
    "Static Site Generator",
    "Clojure",
    "ClojureScript",
]
categories = [
    "clojure",
    "static site generator",
]
series = ["Clojure", "Static Site Generators"]
aliases = ["2017-02-11-Cryogen-static-site-generator"]
thumbnail = "/images/clojure.svg"
+++

Cryogen is a simple static site generator built with [Clojure](http://clojure.org/) — [Cryogen](http://cryogenweb.org/) (by **Carmen La**).
<!--more-->

# From its documentation

Cryogen is shipped on [Leiningen](https://leiningen.org/) so setup is fuss free and there's no need to mess with databases or other CMS systems.

Cryogen reads through a directory containing your [Markdown](http://daringfireball.net/projects/markdown/syntax) or [AsciiDoc](http://asciidoc.org/) content, compiles it into HTML and injects the content into your templates with the [Selmer](https://github.com/yogthos/Selmer) templating system. It then spits out a ready-to-publish website complete with a sitemap and RSS feed.
