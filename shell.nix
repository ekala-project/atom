let
  core = import ./atom-nix/core/mod.nix;
  dev = core.compose ./dev {
    extern.from.nixpkgs = import <nixpkgs>;
    config = { };
  };
in
dev.shell
