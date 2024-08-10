let
  f = import ../../src/core/fromManifest.nix;
  atom = f { __internal__test = true; } (
    # added to test implicit path conversion when path is a string
    builtins.toPath ./test.toml
  );
in
atom
