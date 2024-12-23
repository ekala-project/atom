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
  root,
  cfg,
  get ? { },
}:
let

  std = core.importStd (../std);

  msg = core.errors.debugMsg cfg;

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
          static = with core; {
            inherit
              cfg
              std
              atom
              get
              ;
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

        in
        core.set.inject static [ preOpt ];

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
                trace = core.errors.modPath root dir;
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
          trace = core.errors.modPath root dir;
        in
        assert core.modIsValid module dir;
        core.filterMap g contents // (core.errors.context (msg trace) module);

    in
    if core.hasMod contents then
      core.collectPublic mod
    else
      # Base case: no module
      { };

  atom = core.fix f null root;
in
atom
