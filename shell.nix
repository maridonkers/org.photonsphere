# This was generated by `cabal2nix --shell .`
# Also see: https://robertwpearce.com/hakyll-pt-6-pure-builds-with-nix.html
#
{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  # TODO Hakyll is sometimes marked as broken in NixOS, so use a pinned one.
  inherit (nixpkgs) pkgs;
   myPkgs = import (builtins.fetchGit {
     url = "https://github.com/NixOS/nixpkgs";
     ref = "refs/tags/21.11";
  }) {};

  # myPkgs = nixpkgs;

  f = { mkDerivation, base, hakyll, pandoc, stdenv }:
      mkDerivation {
        pname = "org.photonsphere";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base hakyll pandoc ];
        license = "unknown";
        hydraPlatforms = stdenv.lib.platforms.none;
      };

  haskellPackages = if compiler == "default"
                       then myPkgs.haskellPackages
                       else myPkgs.haskell.packages.${compiler};

  variant = if doBenchmark then myPkgs.haskell.lib.doBenchmark else myPkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if myPkgs.lib.inNixShell then drv.env else drv
