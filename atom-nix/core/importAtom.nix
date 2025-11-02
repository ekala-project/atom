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

  meta = atom.meta or { };

in
mod.compose root {
  inherit
    __internal__test
    config
    ;

  __isStd__ = meta.__is_std__ or false;
}
