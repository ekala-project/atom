# to avoid excessive recursion that can lead to inefficiency or errors
# we cannot compose the individual pieces of the module composer as a regular module
# so instead we abstract them out here, into a manually specified "psuedo-module"
# to keep the core impelementation clean
let
  l = builtins;
  importAtom = import ./importAtom.nix;
  fix = import ../std/fix.nix;
  when = scopedImport { std = builtins; } ../std/set/when.nix;
  filterMap = scopedImport { std = builtins; } ../std/set/filterMap.nix;
  make = scopedImport { std = builtins; } ../std/path/make.nix;
  parse = scopedImport { std = builtins; } ../std/file/parse.nix;
  stdFilter = import ./stdFilter.nix;
  toLowerCase = scopedImport rec {
    std = builtins;
    mod = scopedImport { inherit std mod; } ../std/string/mod.nix;
  } ../std/string/toLowerCase.nix;
  stdToml = l.fromTOML (l.readFile ../std.atom);
  coreToml = l.fromTOML (l.readFile ../core.atom);
in
rec {
  inherit
    fix
    parse
    filterMap
    stdFilter
    stdToml
    coreToml
    ;

  path = {
    inherit make;
  };

  file = {
    inherit parse;
  };
  set = {
    inherit when;
  };

  compose = import ./compose.nix;

  errors = import ./errors.nix;

  features = import ./features.nix;

  lowerKeys = filterMap (k: v: { ${toLowerCase k} = v; });

  collectPublic = filterMap (
    k: v:
    let
      s = toLowerCase k;
    in
    if s == k then null else { ${s} = v; }
  );

  rmNixSrcs =
    path:
    let
      name = baseNameOf path;
    in
    l.path {
      inherit name path;
      filter = (
        path: type:
        let
          file = parse path;
        in
        (type == "regular" && file.ext or null != "nix")
        || (type == "directory" && !l.pathExists "${path}/mod.nix")
      );
    };

  importStd = opts: importAtom { inherit (opts) __internal__test features; };

  modIsValid =
    mod: dir:
    l.isAttrs mod
    || throw ''
      The following module does not evaluate to a valid attribute set:
             ${toString dir}/mod.nix
    '';

  set.inject = l.foldl' (acc: x: acc // when x);

  pureBuiltinsForStd =
    std:
    filterMap (
      builtin: f:
      if stdFilter builtin != null then
        null
      else
        {
          ${builtin} =
            if std ? ${builtin} then
              if l.isAttrs std.${builtin} then
                ## if std exports builtins named the same as a builtin funciton
                ## such as `std.path`, then rexport std's version as a set
                std.${builtin} // { __functor = _: f; }
              else
                ## if std's output is not an attribute set, prefer its version
                std.${builtin}
            else
              ## re-export all non-conflicting builtins
              f;
        }
    ) builtins;

  hasMod = contents: contents."mod.nix" or null == "regular";

  # It is crucial that the directory is a path literal, not a string
  # since the implicit copy to the /nix/store, which provides isolation,
  # only happens for path literals.
  prepDir =
    dir:
    let
      dir' =
        if l.match "^${l.storeDir}/.+" dir != null then
          # this is safe because we will never reimport the full path back to the store
          # only specific files within it, which will have their own context when converted
          # back to a string.
          builtins.unsafeDiscardStringContext dir
        else
          dir;
    in
    if builtins.isPath dir then dir else make /. dir';
}
