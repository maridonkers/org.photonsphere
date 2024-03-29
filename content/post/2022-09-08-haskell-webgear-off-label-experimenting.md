+++
author = "Mari Donkers"
title = "Webgear off-label experimentation"
date = "2022-09-08"
description = "Some quick 'off-label' experimentation with WebGear (a high-performance framework to build composable, type-safe HTTP APIs."
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
aliases = ["2022-09-08-haskell-webgear-off-label-experimenting"]
thumbnail = "/images/haskell.svg"
+++

Some quick 'off-label' experimentation with WebGear (a high-performance framework to build composable, type-safe HTTP APIs. It is designed to make common API development tasks easy. It is also easily extensible to add components needed by your project. – [haskell-webgear/webgear](https://github.com/haskell-webgear/webgear)). Also see earlier [Webgear](/post/2022-09-06-haskell-webgear/) post.
<!--more-->

# Introduction

Experimenting with [Lucid](https://github.com/chrisdone/lucid) templating on the server and automatic recompilation for changes to the [Haskell](https://www.haskell.org/) source code.

The Hello World example from Webgear is used as a starting point and renamed to `webgear-example-hello-lucid`.

# flake.nix

The program name has been changed and the Haskell package `hsPkgs.ghcid` is added to `buildInputs`.

``` nix
  {
  description = "WebGear example project + Lucid - Hello World";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      # Use the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gitignore }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ haskellOverlay ];
        };
        ghcVersion = "ghc924";
        hsPkgs = pkgs.haskell.packages.${ghcVersion};

        pkgName = "webgear-example-hello-lucid";

        haskellOverlay = final: prev: {
          haskell = prev.haskell // {
            packages = prev.haskell.packages // {
              ${ghcVersion} = prev.haskell.packages.${ghcVersion}.override {
                overrides = hfinal: hprev: {
                  webgear-core = hfinal.callPackage
                    ./nix/haskell-packages/webgear-core-1.0.4.nix { };
                  webgear-server = hfinal.callPackage
                    ./nix/haskell-packages/webgear-server-1.0.4.nix { };
                  ${pkgName} = hfinal.callCabal2nix pkgName
                    (gitignore.lib.gitignoreSource ./.) { };
                };
              };
            };
          };
        };
      in {
        packages.default = hsPkgs.${pkgName};
        devShells.default = hsPkgs.shellFor {
          name = pkgName;
          packages = pkgs: [ pkgs.${pkgName} ];
          buildInputs = [
            pkgs.cabal-install
            pkgs.cabal2nix
            hsPkgs.fourmolu
            hsPkgs.ghc
            hsPkgs.ghcid
            pkgs.hlint
            pkgs.haskell-language-server
          ];
          src = null;
        };
      });
}
```

# webgear-example-hello-lucid.cabal

The program name is changed and the `ghc-option` to error out on unused packages `-Wunused-packages` is commented out because the automatic recompilation doesn't like it. Furthermore `lucid` is added to `build-depends`.

``` haskell
cabal-version:      2.4
name:               webgear-example-hello-lucid
version:            1.0.4
description:
  Please see the README at <https://github.com/haskell-webgear/webgear-example-hello#readme>

homepage:
  https://github.com/haskell-webgear/webgear-example-hello#readme

bug-reports:
  https://github.com/haskell-webgear/webgear-example-hello/issues

author:             Raghu Kaippully [changes and additions by Mari Donkers]
maintainer:         rkaippully@gmail.com
copyright:          2021-2022 Raghu Kaippully
license:            MPL-2.0
license-file:       LICENSE
build-type:         Simple
extra-source-files: README.md

source-repository head
  type:     git
  location: https://github.com/haskell-webgear/webgear-example-hello

executable hello
  default-language: Haskell2010
  build-depends:
    , base            >=4.12.0.0 && <5
    , http-types      ^>=0.12
    , lucid
    , warp            ^>=3.3
    , webgear-server  ==1.0.4

  ghc-options:
    -threaded -rtsopts -with-rtsopts=-N -Wall
    -Wno-unticked-promoted-constructors -Wcompat -Widentities
    -Wincomplete-record-updates -Wincomplete-uni-patterns
    -Wmissing-fields -Wmissing-home-modules
    -Wmissing-deriving-strategies -Wpartial-fields
    -Wredundant-constraints -fshow-warning-groups -Werror

  -- -Wunused-packages
  main-is:          Main.hs
  hs-source-dirs:   src
```

# src/Main.hs

The file is changed because of the 'off-label' experimentation (some arbitrary code changes and additions to demonstrate Lucid).

``` haskell
{-# LANGUAGE Arrows               #-}
{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE QuasiQuotes          #-}
{-# LANGUAGE TypeApplications     #-}

import           Control.Category         ((.))
import           Lucid
import           Network.HTTP.Types       (StdMethod (GET))
import qualified Network.HTTP.Types       as HTTP
import           Network.Wai.Handler.Warp (run)
import           Prelude                  hiding ((.))
import           WebGear.Server

title :: Html ()
title = "Webgear hello example with Lucid templating server generated HTML"

stylesheet :: Text
stylesheet = "https://cdnjs.cloudflare.com/ajax/libs/github-fork-ribbon-css/0.2.2/gh-fork-ribbon.min.css"

description :: Text
description = "WebGear is a high-performance framework to build composable, type-safe HTTP APIs. It is designed to make common API development tasks easy. It is also easily extensible to add components needed by your project."

viewport :: Text
viewport = "width=device-width, initial-scale=1"

listItemCount :: Int
listItemCount = 7

pageHead :: Html ()
pageHead = do
  title_ title
  link_ [ rel_ "stylesheet"
          , href_ stylesheet
          ]
  meta_ [ charset_ "utf-8" ]
  meta_ [ name_ "theme-color", content_ "#00d1b2" ]
  meta_ [ httpEquiv_ "X-UA-Compatible"
          , content_ "IE=edge"
          ]
  meta_ [ name_ "viewport"
          , content_ viewport
          ]
  meta_ [ name_ "description"
          , content_ description
          ]
  style_ ".github-fork-ribbon:before { background-color: \"#e59751\" !important; }"

pageBody :: Html ()
pageBody = do
  p_ "This is the first (1st) section in an HTML body."
  p_ [style_ "color:red"] "The second (2nd) section."
  p_ [class_ "third"] "And the third (3rd) section."
  div_ [class_ "table"] "A table:" <> table
  p_ "THIS IS GENERATED BY HASKELL CODE:"
  hr_ []
  div_ [id_ "genlist"] $ do
    p_ "This is an example of Lucid syntax (a list generated by code)."
    ul_ $ gl
    where
      table = table_ [rows_ "2", style_ "border: 1px solid black; padding:10px;"] $ do
        tr_ $ do
          td_ [class_ "top",
               style_ "color:blue; border: 1px dashed black;"]
            $ p_ "1a"
          td_ [class_ "top",
               style_ "color:blue; border: 1px dashed black;"] "1a"
        tr_ $ do
          td_ [class_ "top",
               style_ "color:blue; border: 1px dashed black;"]
            $ p_ "1b"
          td_ [class_ "top",
               style_ "color:blue; border: 1px dashed black;"] "2b"
      gl = mapM_ (\i -> li_ $
                   toHtml $ "Item index [" ++ show i ++ "]") [1..listItemCount]

page :: Html ()
page = doctypehtml_ $ do
  head_ pageHead
  body_ pageBody

lucid :: ServerHandler IO t Response
lucid = proc _ -> do
  let h = page
  unlinkA <<< respondA HTTP.ok200 "text/html"
    -< renderBS h

hello :: ServerHandler
  IO
  (Linked '[PathEnd, PathVar "name" String, Path, Method] Request)
  Response
hello = proc request -> do
  let name = pick @(PathVar "name" String) $ from request
  unlinkA <<< respondA HTTP.ok200 "text/plain" -< "Hello, " <> name

routes :: RequestHandler (ServerHandler IO) '[]
routes = [route|       GET /lucid              |] lucid
           <+> [route| GET /hello/name:String/ |] hello

main :: IO ()
main = run 3000 (toApplication routes)
```

# Development environment

Start the development environment as follows.

``` bash
nix develop
```

# Automatic recompilation

To start automatic recompilation use the following command:

``` bash
ghcid -c 'cabal repl' -T Main.main --restart=./webgear-example-hello-lucid.cabal
```

# Loading the Lucid generated page

Navigate to <http://localhost:3000/lucid> and reload the page in the browser when you have changed something and the automatic recompilation has finished. Note that you will need to terminate the automatic reload command and `exit` out of the development environment and restart both, after changing the `flake.nix` or `webgear-example-hello-lucid.cabal` file.
