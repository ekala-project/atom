let
  dev = (import ./atom-nix/core/importAtom.nix) { path = ./atom-nix/dev; };
in
dev.shell
