let
  f = import ../../atom-nix/core/importAtom.nix;
  atom = f { } (
    # added to test implicit path conversion when path is a string
    builtins.toPath ./bld
  );
in
builtins.deepSeq atom atom
