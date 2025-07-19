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
  features ? null,
  remoteUrl ? null,
  __internal__test ? false,

}:
path':
let
  mod = import ./mod.nix;

  path = mod.prepDir path';

  file = builtins.readFile path;
  config = builtins.fromTOML file;
  atom = config.atom or { };
  id = builtins.seq version (atom.id or (mod.errors.missingAtom path' "id"));
  version = atom.version or (mod.errors.missingAtom path' "version");

  core = config.core or { };
  std = config.std or { };

  features' =
    let
      featSet = config.features or { };
      featIn = if features == null then featSet.default or [ ] else features;
    in
    mod.features.resolve featSet featIn;

  root = mod.prepDir (dirOf path);
  src = builtins.seq id (
    let
      file = mod.parse (baseNameOf path);
      len = builtins.stringLength file.name;
    in
    builtins.substring 0 (len - 1) file.name
  );
  extern = import ./lock.nix root src remoteUrl;

  meta = atom.meta or { };

in
mod.compose {
  inherit
    extern
    __internal__test
    config
    root
    src
    ;
  features = features';
  coreFeatures =
    let
      feat = core.features or mod.coreToml.features.default;
    in
    mod.features.resolve mod.coreToml.features feat;
  stdFeatures =
    let
      feat = std.features or mod.stdToml.features.default;
    in
    mod.features.resolve mod.stdToml.features feat;

  __isStd__ = meta.__is_std__ or false;
}
