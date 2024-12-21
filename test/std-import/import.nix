let
  f = import ../../atom-nix/core/importAtom.nix { __internal__test = true; };
in
{
  default = f (./. + "/default@.toml");
  noStd = f (./. + "/no-std@.toml");
  explicit = f (./. + "/explicit@.toml");
  withLib = f (./. + "/with-lib@.toml");
}
