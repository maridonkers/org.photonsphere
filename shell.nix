# https://nixos.wiki/wiki/Rust

let
  # Pinned nixpkgs, deterministic. 
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "refs/tags/23.05";
  }) {};

  # Rolling updates, not deterministic.
  # pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
  
in pkgs.mkShell {
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  shellHook =
    ''
      export PS1="\[\033[01;32m\][\u@\h\[\033[01;37m\] |mercury| \W\[\033[01;32m\]]\$\[\033[00m\] "
    '';
  
  buildInputs = with pkgs; [
    hugo
  ];
}
