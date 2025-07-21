root: src: url:
let
  lockPath = "${root}/${src}.lock";
  lock = builtins.fromTOML (builtins.readFile lockPath);
  importAtom = import ./importAtom.nix { };
  atomPath =
    dep:
    let
      path = "${root}/${dep.path or dep.id}@.toml";
    in
    if builtins.pathExists path then
      path
    else
      let
        manifest = baseNameOf path;
      in
      "${
        (fetchGit {
          inherit (dep) rev;
          inherit url;
          ref = "refs/eka/atoms/${dep.id}/${dep.version}";
        })
      }/${manifest}";

  depsToSet =
    list:
    builtins.listToAttrs (
      map (dep: {
        name = dep.name or dep.id;
        value = dep;
      }) list
    );

  deps = depsToSet lock.deps or [ ];

  importPin =
    dep: fetch:
    let
      fromDeps = depsToSet fromLock.deps or [ ];
      fromAtom = deps.${dep.from};
      fromPath = atomPath fromAtom;
      fromLockPath = "${(dirOf fromPath)}/${fromAtom.id}.lock";
      fromLock = builtins.fromTOML (builtins.readFile fromLockPath);
      fromName = dep.get or dep.name or "";
      fromDep = fromDeps.${fromName};
    in
    if
      dep ? from
      && fromAtom.type or "" == "atom"
      && builtins.pathExists fromLockPath
      && fromDeps ? ${fromName}
      && builtins.match "^pin.*" fromDep.type != null
    then
      builtins.traceVerbose "using a pin `${fromName}` as `${dep.name}` from atom `${dep.from}` in `${src}`" (
        importDep (fromDep // { path = dep.path or fromDep.path or "."; })
      )
    else
      import (if dep ? path then "${fetch}/${dep.path}" else fetch);

  importDep =
    dep:
    if dep.type == "atom" then
      importAtom (atomPath dep)
    else if dep.type == "pin+git" then
      let
        repo = fetchGit {
          inherit (dep) rev url;
          shallow = true;
        };
      in
      importPin dep repo
    else if dep.type == "pin+tar" then
      let
        fetch = fetchTarball {
          inherit (dep) url;
          sha256 = dep.checksum;
        };
      in
      importPin dep fetch
    else if dep.type == "pin" then
      let
        fetch = builtins.fetchurl {
          inherit (dep) url;
          sha256 = dep.checksum;
        };
      in
      importPin dep fetch
    else
      { };

in
if builtins.pathExists lockPath && lock.version == 1 then
  let
    from = builtins.mapAttrs (_: dep: importDep dep) deps;
    get = builtins.listToAttrs (
      map (src: {
        name = src.pname or src.name;
        value =
          (builtins.removeAttrs src [ "type" ])
          // (
            if src.type == "build" then
              {
                src = import <nix/fetchurl.nix> {
                  inherit (src) url;
                  hash = src.checksum;
                };
              }
            else
              { }
          );
      }) lock.srcs or [ ]
    );

  in
  {
    inherit from get;
  }
else
  { }
