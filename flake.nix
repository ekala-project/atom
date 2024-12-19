{
  description = "Composable Nix Modules";

  outputs = _: {
    core = import ./src/core/mod.nix;
    importAtom = import ./src/core/importAtom.nix;
    mkAtomicFlake = import ./legacy-nix/mkAtomicFlake.nix;
  };
}
