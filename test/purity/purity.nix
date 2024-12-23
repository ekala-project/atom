let
  f = import ../../atom-nix/core/compose.nix;
  atom = f {
    get.stdFilter = import ../../atom-nix/core/stdFilter.nix;
    cfg = { };
    root =
      # added to test implicit path conversion when path is a string
      builtins.toPath ./test;
  };
in
atom
