/**
  # `compose`

  ## Function

  Atom's composer demonstrates a module system for Nix.

  It searches from a passed root directory for other dirs containing a `mod.nix` file.
  It's terminating condition is when a `mod.nix` does not exist. Leaving directories without
  one unexplored.

  Along the way it auto-imports any other Nix files in the same directory as `mod.nix` as module
  members. Crucially, every imported file is called with `scopedImport` provding a well defined
  global scope for every module: `mod`, `pre`, `atom` and `std`.

  `mod`: recursive reference to the current module
  `pre`: parent module, including private members
  `atom`: top-level module and it's children's public memberss
  `std`: a standard library of generally useful Nix functions

  ## Future Work

  The Nix language itself could incorporate syntax like:

  ```
  {
    pub foo;
  }
  ```

  Here, `foo` could be implicitly defined in a similar, but more sophisticated way to Atom
  when not explicitly set.

  Further, Nix could introduce modules as top-level namespaces, with simplified syntax:

  ```
    foo = 1;
    pub bar = mod.foo;
  ```

  This would evaluate to `{ bar = 1; }` publicly and `{ foo, bar = 1; }` for child modules.

  These additions, combined with Atom's existing feature set, would:
  - Streamline development
  - Improve code clarity
  - Extend Nix's capabilities while preserving its core principles

  Atom, therefore, serves as a useable proof-of-concept for these ideas. Its ultimate goal is to
  inspire  improvements in the space that would eventually render Atom obsolete. By demonstrating
  these concepts, we aim to contribute to Nix's evolution and simplify complex operations for
  developers.

  Until such native functionality exists, Atom provides a glimpse of these
  possibilities within the current landscape.
*/
let
  l = builtins;
  core = import ./mod.nix;
in
{
  src,
  root,
  config,
  extern ? { },
  features ? [ ],
  # internal features of the composer function
  stdFeatures ? core.stdToml.features.default or [ ],
  coreFeatures ? core.coreToml.features.default,
  # enable testing code paths
  __internal__test ? false,
  __isStd__ ? false,
}:
let
  par = (root + "/${src}");

  std = core.importStd {
    features = stdFeatures;
    inherit __internal__test;
  } ../std.atom;

  coreFeatures' = core.features.resolve core.coreToml.features coreFeatures;
  stdFeatures' = core.features.resolve core.stdToml.features stdFeatures;

  __atom = config // {
    features = config.features or { } // {
      resolved = {
        atom = features;
        core = coreFeatures';
        std = stdFeatures';
      };
    };
  };

  msg = core.errors.debugMsg config;

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
          scope' = with core; {
            inherit __atom;
            mod = modScope;
            builtins = std;
            import = errors.import;
            scopedImport = errors.import;
            __fetchurl = errors.fetch;
            __currentSystem = errors.system;
            __currentTime = errors.time 0;
            __nixPath = errors.nixPath [ ];
            __storePath = errors.storePath;
            __getEnv = errors.getEnv "";
            __getFlake = errors.import;
          };

          scope'' = core.set.inject scope' [
            preOpt
            {
              _if = !__isStd__ && l.elem "std" coreFeatures';
              inherit std;
            }
            {
              _if = !__isStd__;
              atom = atomScope;
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
                inherit __isStd__ __internal__test;
                src = core;
              };
            }
          ];
        in
        scope'';

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = core.path.make dir name;
          file = core.file.parse name;
          member = Import (l.path { inherit path name; });
          module = core.path.make path "mod.nix";
        in
        if type == "directory" && l.pathExists module then
          { ${name} = f ((core.lowerKeys mod) // core.set.when preOpt) path; }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          {
            ${file.name} =
              let
                trace = core.errors.modPath par dir;
              in
              core.errors.context (msg "${trace}.${file.name}") member;
          }
        else
          null # Ignore other file types
      ;

      modScope = core.lowerKeys (l.removeAttrs mod [ "mod" ] // { outPath = core.rmNixSrcs dir; });

      mod =
        let
          path = core.path.make dir "mod.nix";
          module = Import (
            l.path {
              inherit path;
              name = baseNameOf path;
            }
          );
          trace = core.errors.modPath par dir;
        in
        assert core.modIsValid module dir;
        core.filterMap g contents // (core.errors.context (msg trace) module);

    in
    if core.hasMod contents then
      core.collectPublic mod
    else
      # Base case: no module
      { };

  atomScope = l.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf par)
  ];

  atom =
    let
      fixed = core.fix f null par;
    in
    core.set.inject fixed [
      ({ _if = __isStd__; } // core.pureBuiltinsForStd fixed)
      {
        _if = __isStd__ && l.elem "lib" __atom.features.resolved.atom;
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
  || core.errors.warn ''
    in ${toString ./default.nix}:
    Internal testing functionality is enabled via the `__test` boolean.
    This should never be `true` except in internal test runs.
  '' true;
atom
