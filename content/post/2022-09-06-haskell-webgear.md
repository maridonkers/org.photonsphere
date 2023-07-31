+++
author = "Mari Donkers"
title = "Webgear"
date = "2022-09-06"
description = "WebGear is a high-performance framework to build composable, type-safe HTTP APIs. It is designed to make common API development tasks easy. It is also easily extensible to add components needed by your project."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "Internet",
    "HTML",
    "API",
    "Nix",
    "Webgear",
]
categories = [
    "linux",
    "haskell",
]
series = ["Linux", "Haskell"]
aliases = ["2022-09-06-haskell-webgear"]
thumbnail = "/images/haskell.svg"
+++

WebGear is a high-performance framework to build composable, type-safe HTTP APIs. It is designed to make common API development tasks easy. It is also easily extensible to add components needed by your project. – [haskell-webgear/webgear](https://github.com/haskell-webgear/webgear) (by [Raghu Kaippully](https://github.com/rkaippully)).
<!--more-->

# Introduction

From the [Webgear](https://haskell-webgear.github.io/) documentation:

"Webgear is a framework to build HTTP APIs in Haskell. WebGear helps to run these APIs as a web application, automatically generate [OpenAPI](https://en.wikipedia.org/wiki/OpenAPI_Specification) documentation, and extract other static information about the APIs in general.

WebGear is built on a philosophy that users need not be experts on advanced Haskell features to use a web framework. While WebGear internally uses many advanced language extensions, considerable effort is spent in exposing only a small portion of it in user APIs so that you need not be an expert to use them. It also has comprehensive documentation and examples that shortens the learning curve.

WebGear is very flexible, allowing you to build your project the way you want. It is very easy to extend or completely replace most of the components to make it work the way you need it to."

"Learn more about WebGear and how it compares against alternatives in the [user guide](https://haskell-webgear.github.io/user_guide/1.0.2/index.html)."

# Batteries Included

Authentication, validation, JSON support are all built-in.

# Why use WebGear?

Quoted directly from the [Webgear user guide](https://haskell-webgear.github.io/user_guide/1.0.2/index.html):

"If you are already familiar with other Haskell web frameworks, you might be interested in how WebGear compares against them. This section compares WebGear against some popular frameworks to give you an idea of why it is useful."

# Comparison against other web frameworks

Detailed [comparison](https://haskell-webgear.github.io/user_guide/1.0.2/index.html) — Webgear ([haskell-webgear/webgear](https://github.com/haskell-webgear/webgear)) compared against Servant ([haskell-servant/servant](https://github.com/haskell-servant/servant)), IHP ([digitallyinduced/ihp](https://github.com/digitallyinduced/ihp)), Scotty ([scotty-web/scotty](https://github.com/scotty-web/scotty)).

# Examples

Examples of WebGear applications can be found at:

- [Hello World](https://github.com/haskell-webgear/webgear-example-hello)
- [A basic CRUD app that operates on user resources](https://github.com/haskell-webgear/webgear-example-users)
- [Realworld — a medium.com clone (called conduit)](https://github.com/haskell-webgear/webgear-example-realworld)
