let
  f = import ../../src/core/fromManifest.nix { __internal__test = true; };
in
{
  default = f ./default.toml;
  noStd = f ./no-std.toml;
  explicit = f ./explicit.toml;
  withPkgLib = f ./pkglib.toml;
}
