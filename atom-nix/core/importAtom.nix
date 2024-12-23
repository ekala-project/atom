/**
  # `importAtom`

  > #### ⚠️ Warning ⚠️
  >
  > `importAtoms` current implementation should be reduced close to:
  > ```nix
  >   compose <| std.fromJSON
  > ```

  In other words, compose should receive a dynamically generated json from the CLI.

  If nix-lang gets some sort of native (and performant!) schema validation such as:
  [nixos/nix#5403](https://github.com/NixOS/nix/pull/5403) in the future, we can look at
  revalidating on the Nix side as an extra precaution, but initially, we just assume we have a
  valid input (and the CLI should type check on it's end)
*/
{
  cfg ? { },
  path,
}:
let
  mod = import ./mod.nix;

  dir = mod.prepPath path;

  file = builtins.readFile (dir + "@.toml");
  manifest = builtins.fromTOML file;
  atom = manifest.atom or { };
  id = builtins.seq version (atom.id or (mod.errors.missingAtom path "id"));
  version = atom.version or (mod.errors.missingAtom path "version");

  get = { }; # TODO: handled in https://github.com/ekala-project/atom/pull/42

  parsedCfg =
    if builtins.isString cfg then
      builtins.fromJSON cfg
    else if builtins.isPath cfg then
      builtins.fromJSON (builtins.readFile cfg)
    else if builtins.isAttrs cfg then
      cfg
    else
      mod.errors.warn "ignoring invalid config" { };

in
mod.compose {
  inherit get;

  root = builtins.seq id dir;
  cfg = parsedCfg // {
    inherit (manifest) atom;
  };
}
