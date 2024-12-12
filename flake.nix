{
  description = "Composable Nix Modules";
  outputs = _: {
    importAtom = import ./src/core/importAtom.nix;
    core = import ./src/core/mod.nix;
  };
}
