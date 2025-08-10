let
  dev = (import ./atom-nix/core/importAtom.nix) { } (./atom-nix/dev);
in
dev.shell
