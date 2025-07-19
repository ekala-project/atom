root: src:
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
  { }
