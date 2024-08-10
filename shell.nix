let
  dev = (import ./src/core/fromManifest.nix) { } ./src/dev.toml;
in
dev.shell
