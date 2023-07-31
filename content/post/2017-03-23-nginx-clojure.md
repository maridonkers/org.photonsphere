+++
author = "Mari Donkers"
title = "nginx-clojure - lean Clojure deployment"
date = "2017-03-23"
description = "Nginx module for embedding Clojure / Java / Groovy programs, typically those Ring based handlers – Nginx-Clojure"
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Linux",
    "Server",
    "Internet",
    "GUI",
    "Java",
    "Clojure",
    "ClojureScript",
]
categories = [
    "clojure",
    "server",
]
series = ["Linux", "Server"]
aliases = ["2017-03-23-nginx-clojure"]
thumbnail = "/images/nginx.svg"
+++

[Nginx](http://nginx.org/) module for embedding [Clojure](http://clojure.org/) / [Java](http://openjdk.java.net/) / [Groovy](http://groovy-lang.org/) programs, typically those [Ring](https://github.com/ring-clojure/ring/blob/master/SPEC) based handlers – [Nginx-Clojure](http://nginx-clojure.github.io/) (by **Zhang, Yuexiang (xfeep)**).
<!--more-->

# DZone article on Nginx-Clojure

[Fast Clojure/Java Web Apps on NGINX Without a Java Web Server](https://dzone.com/articles/develope-high-performance).

# Fast Clojure/Java Web Apps on NGINX Without a Java Web Server

[Nginx-Clojure](https://github.com/xfeep/nginx-clojure) is a [Nginx](http://nginx.org/) module for embedding Clojure or Java programs, typically those [Ring](https://github.com/ring-clojure/ring/blob/master/SPEC) based handlers. It is an opensource project hosted on Github. With it we can develope high performance Clojure/Java web apps on Nginx without any Java web server and with several benefits:

- Clojure/Java controlled static files will get almost the same performance with Nginx static file service;
- we just deploy one Nginx (compiled with Nginx-Clojure module) server instead of Nginx + some Java web server, eg. Tomcat, Jetty etc.;
- [Ring Handler](https://github.com/ring-clojure/ring/blob/master/SPEC) is dead easy compared to Java Servlet;
- we can use Nginx modules such as GZip, Image Filter etc. with our static and dynamic content on the fly without any cost of Proxy level;
- we can use Java rewrite handler + proxy_pass to implement a dynamic proxy/balancer very quickly.
