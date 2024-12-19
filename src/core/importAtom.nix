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
  system ? null,
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
      # TODO native doesn't exist yet
      fetcher = nix.fetcher or "native";
      throwMissingNativeFetcher = abort "Native fetcher isn't implemented yet";

      fetcherConfig = config.fetcher or { };
      npinRoot = fetcherConfig.npin.root or "npins";
      pins = import (dirOf path + "/${npinRoot}");

      fetchEnabledNpinsDep =
        depName: depConfig:
        let
          depIsEnabled =
            (depConfig.optional or false && builtins.elem depName features') || (!depConfig.optional or false);

          npinSrc = "${pins.${depConfig.name or depName}}/${depConfig.subdir or ""}";

          applyArguments =
            appliedFunction: nextArgument:
            let
              argsFromDeps = depConfig.argsFromDeps or true && builtins.isAttrs nextArgument;
              argIntersectedwithDeps = nextArgument // (builtins.intersectAttrs nextArgument extern);
            in
            if argsFromDeps nextArgument then
              appliedFunction argIntersectedwithDeps
            else
              appliedFunction nextArgument;

          dependency =
            if depConfig.import or false then
              if depConfig.args or [ ] != [ ] then
                builtins.foldl' applyArguments (import npinSrc) depConfig.args
              else
                import npinSrc
            else
              npinSrc;
        in
        if depIsEnabled then { "${depName}" = dependency; } else null;

      npinsDeps = mod.filterMap fetchEnabledNpinsDep config.fetch or { };

    in
    if fetcher == "npins" then
      npinsDeps
    else if fetcher == "native" then
      throwMissingNativeFetcher
    else
      { };

  meta = atom.meta or { };

in
mod.compose {
  inherit
    src
    root
    config
    system
    extern
    __internal__test
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
