let
  dev = (import ./atom-nix/core/importAtom.nix) { } (./. + "/atom-nix/dev@.toml");
in
dev.shell
