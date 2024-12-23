let
  dev = (import ./atom-nix/core/compose.nix) {
    root = ./atom-nix/dev;
    cfg = { };
    get.pkgs = import <nixpkgs> { };
  };
in
dev.shell
