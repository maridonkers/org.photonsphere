+++
author = "Mari Donkers"
title = "Remove duplicates from Instapaper HTML export"
date = "2019-02-18"
description = "Over the course of your day, you'll encounter things you want to save for later. With Instapaper, you simply push a button in your browser, or choose \"send to Instapaper\" in a linked mobile app. Instapaper then saves it for you, and makes it available in a beautiful, uncluttered, reading-optimized format on or your browser."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Clojure",
    "Internet",
    "HTML",
]
categories = [
    "clojure",
]
series = ["Clojure"]
aliases = ["2019-02-18-instapaper-export"]
thumbnail = "/images/clojure.svg"
+++

[Instapaper](https://www.instapaper.com/help) turns web content – articles, stories, posts, videos, and even long emails – into a great reading experience.

Over the course of your day, you'll encounter things you want to save for later. With Instapaper, you simply push a button in your browser, or choose "send to Instapaper" in a linked mobile app. Instapaper then saves it for you, and makes it available in a beautiful, uncluttered, reading-optimized format on or your browser.
<!--more-->

# Hickory

Hickory parses [HTML](https://en.wikipedia.org/wiki/HTML) into Clojure data structures, so you can analyze, transform, and output back to HTML. HTML can be parsed into hiccup vectors, or into a map-based DOM-like format very similar to that used by clojure.xml. It can be used from both [Clojure](http://clojure.org/) and [Clojurescript](http://clojurescript.org/). – [Hickory](https://github.com/davidsantiago/hickory) (by **[David Santiago](https://github.com/davidsantiago)**)

# Duplicate links in HTML export file

When adding links to Instapaper, sometimes duplicates are stored. These will also be in an Instapaper HTML export file.

A tool (built with Hickory) to remove duplicate hyperlinks from [Instapaper](https://www.instapaper.com/) HTML export files – [maridonkers / instapaper](https://github.com/maridonkers/instapaper) (by [Mari Donkers](https://github.com/maridonkers))

# Binary download

The ready for use binary download can be found here: [instapaper.jar](http://photonsphere.org/downloads/instapaper.jar)

Execute via the following command ([Java](https://www.java.com/) must be installed on your machine):

``` bash
java -jar instapaper.jar inputfile.html outputfile.html
```

(Where inputfile.html is the Instapaper HTML export file, which can be generated via Instapaper -\> Settings -\> Export -\> Download HTML file.)
