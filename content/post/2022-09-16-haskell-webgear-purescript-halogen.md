+++
author = "Mari Donkers"
title = "Webgear server + Halogen client"
date = "2022-09-16"
description = "The Webgear realworld Haskell example (server) and the Real World Halogen Purescript example (client) combined into Conduit."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "PureScript",
    "Internet",
    "HTML",
    "JavaScript",
    "API",
    "Nix",
    "Webgear",
]
categories = [
    "linux",
    "haskell",
    "purescript",
]
series = ["Linux", "Haskell", "PureScript"]
aliases = ["2022-09-16-haskell-webgear-purescript-halogen"]
thumbnail = "/images/purescript.png"
+++

The [Webgear realworld](https://github.com/haskell-webgear/webgear-example-realworld) `Haskell` example (server) and the [Real World Halogen](https://github.com/thomashoneyman/purescript-halogen-realworld) `Purescript` example (client) combined into `Conduit` ([gothinkster/realworld](https://github.com/gothinkster/realworld)) — what's described as "The mother of all demo apps" (fullstack Medium.com clone)
<!--more-->

# Introduction

At the server [Haskell](https://www.haskell.org/) is used (i.e. [Webgear](https://haskell-webgear.github.io/)) and at the client [PureScript](https://www.purescript.org/) (i.e. [Halogen](https://purescript-halogen.github.io/purescript-halogen/)). The `Conduit` ([gothinkster/realworld](https://github.com/gothinkster/realworld)) examples for Webgear and Halogen are used at respectively the server and client. The `ember.js` client in the Webgear example is replaced with the `Halogen` client.

A folder is created for the project (in which <span class="spurious-link" target="Client (Halogen Purescript)">*client*</span> and <span class="spurious-link" target="Server (Webgear Haskell)">*server*</span> subdirectories will be created, further on in this text).

``` bash
mkdir webgearhalogen
```

# Nix prerequisite

You'll need to have `Nix` installed, per instructions [here](https://nixos.org/download.html#download-nix).

# Client (Halogen Purescript)

The [thomashoneyman/purescript-halogen-realworld](https://github.com/thomashoneyman/purescript-halogen-realworld) example is cloned into a client subdirectory.

``` bash
git clone https://github.com/thomashoneyman/purescript-halogen-realworld client
```

As per instructions in `README.md` a development shell is started and [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) dependencies are installed.

``` bash
cd webgearhalogen/client
nix develop
npm install
```

The `baseUrl` is changed in the `src/Main.purs` file, so that `localhost` is served.

`src/Main.purs`

``` purescript
let
  -- baseUrl = BaseURL "https://api.realworld.io"
  baseUrl = BaseURL ""
  logLevel = Dev
```

Now the `PureScript` code is compiled to `JavaScript` code (producing a `dist/main.js` file).

Change the `dist/index.html` file to refer to the `ui/assets/main.js` location.

``` html
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Conduit</title>
    <link href="//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="//fonts.googleapis.com/css?family=Titillium+Web:700|Source+Serif+Pro:400,700|Merriweather+Sans:400,700|Source+Sans+Pro:400,300,600,700,300italic,400italic,600italic,700italic" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="//demo.productionready.io/main.css" />
  </head>
  <body>
    <script src="ui/assets/main.js"></script>
  </body>
</html>
```

Compile the client and exit the client development shell.

``` bash
npm run bundle
exit
```

# Server (Webgear Haskell)

The [webgear-example-realworld](https://github.com/haskell-webgear/webgear-example-realworld) example is cloned into a server subdirectory (hence a sibling of the <span class="spurious-link" target="Client (Halogen Purescript)">*client*</span> subdirectory).

``` bash
git clone https://github.com/haskell-webgear/webgear-example-realworld server
```

Delete `ui/index.html` and clear the `ui/assets` subdirectory. Create symlinks to the Halogen files.

``` bash
cd webgearhalogen/server

cd ui
rm index.html
ln -s ../../client/dist/index.html

rm -rf assets
mkdir assets
cd assets
ln -s ../../../client/dist/main.js
```

# Start the server

## Configure server

Add `hsPkgs.ghcid` to `server/flake.nix`. Also beware that the `nix develop` command may take a while to complete and uses lots of memory — this can be greatly reduced by commenting out `pkgs.haskell-language-server` in `flake.nix` prior to running `nix develop`.

`flake.nix`

``` nix
devShells.default = hsPkgs.shellFor {
  name = pkgName;
  packages = pkgs: [ pkgs.${pkgName} ];
  buildInputs = [
    pkgs.cabal-install
    pkgs.cabal2nix
    hsPkgs.fourmolu
    hsPkgs.ghc
    pkgs.hlint
    # pkgs.haskell-language-server
    hsPkgs.ghcid
 ];
 src = null;
};
```

Change `server/webgear-example-realworld.cabal` to comment out `-Wunused-packages`. in `ghc-options`, because `ghcid` doesn't like it.

`webgear-example-realworld.cabal`

``` cabal
ghc-options:        -threaded
                      -rtsopts
                      -with-rtsopts=-N
                      -Wall
                      -Wno-unticked-promoted-constructors
                      -Wcompat
                      -Widentities
                      -Wincomplete-record-updates
                      -Wincomplete-uni-patterns
                      -Wmissing-fields
                      -Wmissing-home-modules
                      -Wmissing-deriving-strategies
                      -Wpartial-fields
                      -Wredundant-constraints
                      -- -Wunused-packages
                      -Werror
                      -fshow-warning-groups
```

## Start the server

    cd webgearhalogen/server
    nix develop
    ghcid -c 'cabal repl' -T Main.main --restart=./webgear-example-realworld.cabal

# Navigate to site

Navigate to your site at <http://localhost:3000>, where one of the already precreated logins can be used (also see the [Webgear realworld](https://github.com/haskell-webgear/webgear-example-realworld) example documentation).

- Email: \`arya@winterfell.com\` Password: \`valar_morghulis\`
- Email: \`jon@winterfell.com\` Password: \`winter_is_coming\`
