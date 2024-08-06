let
  f = import ../../. { __internal__test = true; };
in
{
  default = f ./default.toml;
  noStd = f ./no-std.toml;
  explicit = f ./explicit.toml;
  withNixpkgsLib = f ./pkglib.toml;
}