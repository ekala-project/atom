let
  compose = import ./atom-nix;
  dev = compose ./dev {
    extern.from.nixpkgs = import <nixpkgs>;
    config = { };
  };
in
dev.shell
