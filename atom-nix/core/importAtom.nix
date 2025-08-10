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
  remoteUrl ? null,
  __internal__test ? false,

}:
root':
let
  mod = import ./mod.nix;

  root = mod.prepDir root';

  file = builtins.readFile (root + "/atom.toml");
  config = builtins.fromTOML file;
  atom = config.atom or { };
  id = builtins.seq version (atom.id or (mod.errors.missingAtom root' "id"));
  version = atom.version or (mod.errors.missingAtom root' "version");

  extern = import ./lock.nix root' id remoteUrl;

  meta = atom.meta or { };

in
mod.compose {
  inherit
    extern
    __internal__test
    config
    root
    ;

  __isStd__ = meta.__is_std__ or false;
}
