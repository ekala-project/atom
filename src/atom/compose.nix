let
  l = builtins;
  src = import ./mod.nix;
in
{
  config,
  extern ? { },
  features ? [ ],
  # internal features of the composer function
  stdFeatures ? src.stdToml.features.default or [ ],
  composeFeatures ? src.atomToml.features.default,
  # enable testing code paths
  __internal__test ? false,
  __isStd__ ? false,
}:
dir':
let
  dir = src.prepDir dir';

  std = src.readStd {
    features = stdFeatures;
    inherit __internal__test;
  } ../std.toml;

  composeFeatures' = src.features.resolve src.atomToml.features composeFeatures;
  stdFeatures' = src.features.resolve src.stdToml.features stdFeatures;

  __atom = config // {
    features = config.features or { } // {
      resolved = {
        atom = features;
        compose = composeFeatures';
        std = stdFeatures';
      };
    };
  };

  f =
    f: pre: dir:
    let
      contents = l.readDir dir;

      preOpt = {
        _if = pre != null;
        inherit pre;
      };

      scope =
        let
          scope' = with src; {
            inherit __atom;
            mod = self';
            builtins = errors.builtins;
            import = errors.import;
            scopedImport = errors.import;
            __fetchurl = errors.fetch;
            __currentSystem = errors.system;
            __currentTime = errors.time;
            __nixPath = errors.nixPath;
            __storePath = errors.storePath;
            __getEnv = errors.getEnv;
            __getFlake = errors.import;
          };

          scope'' = src.set.inject scope' [
            preOpt
            {
              _if = !__isStd__ && l.elem "std" composeFeatures';
              inherit std;
            }
            {
              _if = !__isStd__;
              atom = atom';
            }
            {
              _if = __isStd__;
              std = l.removeAttrs (extern // atom) [ "std" ];
            }
            {
              _if = __internal__test;
              # information about the internal module system itself
              # available to tests
              __internal = {
                # a copy of the global scope, for testing if values exist
                # for our internal testing functions
                scope = scope'';
                inherit src __isStd__ __internal__test;
              };
            }
          ];
        in
        scope'';

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = src.file.parse name;
        in
        if type == "directory" && l.pathExists "${toString path}/mod.nix" then
          { ${name} = f ((src.lowerKeys self) // src.set.when preOpt) path; }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          { ${file.name} = Import "${path}"; }
        else
          null # Ignore other file types
      ;

      self' = src.lowerKeys (l.removeAttrs self [ "mod" ] // { outPath = src.rmNixSrcs dir; });

      self =
        let
          mod = Import "${dir + "/mod.nix"}";
        in
        assert src.modIsValid mod dir;
        src.filterMap g contents // mod;

    in
    if src.hasMod contents then
      src.collectPublic self
    else
      # Base case: no module
      { };

  atom' = l.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf dir)
  ];

  atom =
    let
      fixed = src.fix f null dir;
    in
    src.set.inject fixed [
      (
        {
          _if = __isStd__;
        }
        // src.pureBuiltins
        // {
          path = fixed.path // {
            __functor = _: l.path;
          };
        }
      )
      {
        _if = __isStd__ && l.elem "pkg_lib" __atom.features.resolved.atom;
        inherit (extern) lib;
      }
      {
        _if = __isStd__ && __internal__test;
        __internal = {
          inherit __isStd__;
        };
      }
    ];
in
assert
  !__internal__test
  # older versions of Nix don't have the `warn` builtin
  || l.warn or l.trace ''
    in ${toString ./default.nix}:
    Internal testing functionality is enabled via the `__test` boolean.
    This should never be `true` except in internal test runs.
  '' true;
atom
