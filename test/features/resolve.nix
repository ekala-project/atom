let
  f = import ../../src/core/fromManifest.nix { __internal__test = true; };
in
{
  recursive-features = f ./recursive-features.toml;
  recursive-features-loop = f ./recursive-features-loop.toml;
}
