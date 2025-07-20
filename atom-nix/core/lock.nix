root: src: url:
let
  lockPath = "${root}/${src}.lock";
  lock = builtins.fromTOML (builtins.readFile lockPath);
in
if builtins.pathExists lockPath && lock.version == 1 then
  let
    from = builtins.listToAttrs (
      map (dep: {
        name = dep.name or dep.id;
        value =
          let
            path = "${root}/${dep.path or dep.id}@.toml";
          in
          if dep.type == "atom" then
            if builtins.pathExists path then
              (import ./importAtom.nix) { } path
            else
              let
                manifest = baseNameOf path;
              in
              (import ./importAtom.nix) { }
                "${
                  (fetchGit {
                    inherit (dep) rev;
                    inherit url;
                    ref = "refs/eka/atoms/${dep.id}/${dep.version}";
                  })
                }/${manifest}"
          else if dep.type == "pin+git" then
            let
              repo = fetchGit {
                inherit (dep) rev url;
                shallow = true;
              };
            in
            import (if dep ? path then "${repo}/${dep.path}" else repo)
          else if dep.type == "pin+tar" then
            let
              fetch = fetchTarball {
                inherit (dep) url;
                sha256 = dep.checksum;
              };
            in
            import (if dep ? path then "${fetch}/${dep.path}" else fetch)
          else if dep.type == "pin" then
            let
              fetch = builtins.fetchurl {
                inherit (dep) url;
                sha256 = dep.checksum;
              };
            in
            import (if dep ? path then "${fetch}/${dep.path}" else fetch)
          else if dep.type == "src" then
            let
              src = import <nix/fetchurl.nix> {
                inherit (dep) url;
                hash = dep.checksum;
              };
            in
            src
          else
            { };
      }) lock.deps or [ ]
    );
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
