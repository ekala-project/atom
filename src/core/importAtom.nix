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

  backend = config.backend or { };
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
      conf = config.fetcher or { };
      f = conf.${fetcher} or { };
      fetchRoot = f.root or "npins";
    in
    if fetcher == "npins" then
      let
        pins = import (dirOf path + "/${fetchRoot}");
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
        if (v.optional or false && builtins.elem k features') || (!v.optional or false) then
          { "${k}" = val; }
        else
          null
      ) config.fetch or { }
    # else if fetcher = "native", etc
    else
      let
        lockPath = "${root}/${src}.lock";
        lock = builtins.fromTOML (builtins.readFile lockPath);
      in
      if builtins.pathExists lockPath && lock.version == 1 then
        builtins.listToAttrs (
          map (dep: {
            name = dep.name or dep.id;
            value =
              let
                path = "${root}/${dep.path or dep.id}@.toml";
              in
              if dep ? version && dep ? id then
                if builtins.pathExists path then
                  (import ./importAtom.nix) { } path
                else
                  let
                    spec = baseNameOf path;
                  in
                  (import ./importAtom.nix) { }
                    "${
                      (builtins.fetchGit {
                        inherit (dep) url rev;
                        ref = "refs/atoms/${dep.id}/${dep.version}/atom";
                      })
                    }/${spec}"
              else if dep ? rev then
                let
                  repo = builtins.fetchGit {
                    inherit (dep) url rev;
                    shallow = true;
                  };
                in
                if dep ? path then import "${repo}/${dep.path}" else import repo
              else
                { };
          }) lock.deps
        )
      else
        { };

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
