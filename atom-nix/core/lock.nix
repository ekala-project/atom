root: src: url:
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
        if dep.type == "atom" then
          if builtins.pathExists path then
            (import ./importAtom.nix) { } path
          else
            let
              spec = baseNameOf path;
            in
            (import ./importAtom.nix) { }
              "${
                (builtins.fetchGit {
                  inherit (dep) rev;
                  inherit url;
                  ref = "refs/eka/atoms/${dep.id}/${dep.version}";
                })
              }/${spec}"
        else if dep.type == "pin+git" then
          let
            repo = builtins.fetchGit {
              inherit (dep) rev url;
              shallow = true;
            };
          in
          import (if dep ? path then "${repo}/${dep.path}" else repo)
        else if dep.type == "pin" then
          let
            fetch = builtins.fetchurl {
              inherit (dep) url;
              sha256 = dep.checksum;
            };
          in
          import (if dep ? path then "${fetch}/${dep.path}" else fetch)
        else
          { };
    }) lock.deps
  )
else
  { }
