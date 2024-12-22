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
  __internal__test ? false,
  __isStd__ ? false,
}:
path':
let
  mod = import ./mod.nix;

  path = mod.prepDir path';

  file = builtins.readFile path;
  manifest = builtins.fromTOML file;
  atom = manifest.atom or { };
  id = builtins.seq version (atom.id or (mod.errors.missingAtom path' "id"));
  version = atom.version or (mod.errors.missingAtom path' "version");

  backend = manifest.backend or { };
  nix = backend.nix or { };

  root = mod.prepDir (dirOf path);
  src = builtins.seq id (
    let
      file = mod.parse (baseNameOf path);
      len = builtins.stringLength file.name;
    in
    builtins.substring 0 (len - 1) file.name
  );
  extern =
    let
      fetcher = nix.fetcher or "native"; # native doesn't exist yet
      conf = manifest.fetcher or { };
      f = conf.${fetcher} or { };
      root = f.root or "npins";
    in
    if fetcher == "npins" then
      let
        pins = import (dirOf path + "/${root}");
      in
      mod.filterMap (
        k: v:
        let
          src = "${pins.${v.name or k}}/${v.subdir or ""}";
          val =
            if v.import or false then
              if v.args or [ ] != [ ] then
                builtins.foldl' (
                  f: x:
                  let
                    intersect = x // (builtins.intersectAttrs x extern);
                  in
                  if builtins.isAttrs x then f intersect else f x
                ) (import src) v.args
              else
                import src
            else
              src;
        in
        {
          "${k}" = val;
        }
      ) manifest.fetch or { }
    # else if fetcher = "native", etc
    else
      { };

in
mod.compose {
  inherit
    extern
    __internal__test
    __isStd__
    root
    src
    ;

  cfg = {
    inherit (manifest) atom;
  };
}
