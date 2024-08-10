let
  imap = scopedImport { std = builtins; } ../std/list/imap.nix;
  sublist = scopedImport { std = builtins; } ../std/list/sublist.nix;
  digits = n: builtins.stringLength (builtins.toString n);
  spaces = n: toString (builtins.genList (x: " ") n);
  right =
    str:
    let
      match = builtins.match "^( *)[^ ].*" str;
    in
    if match == null then
      builtins.stringLength str # If the string is all spaces
    else
      builtins.stringLength (builtins.head match);

in
{
  import = abort "Importing arbitrary Nix files is forbidden. Declare your dependencies via the module system instead.";
  builtins = abort "Please access builtins uniformly via the `std` scope.";
  fetch = abort "Ad hoc fetching is illegal. Declare dependencies statically in the manifest instead.";
  system = abort "Accessing the current system is impure. Declare supported systems in the manifest.";
  time = abort "Accessing the current time is impure & illegal.";
  nixPath = abort "The NIX_PATH is an impure feature, and therefore illegal.";
  storePath = abort "Making explicit dependencies on store paths is illegal.";
  getEnv = abort "Accessing environmental variables is impure & illegal.";
  missingName =
    file:
    let
      name = baseNameOf file;
      contents = builtins.readFile file;
      lines = builtins.filter builtins.isString (builtins.split "\n" contents);
      l = builtins.length lines;
      num = imap (i: line: { inherit i line; }) lines;
      atom = builtins.filter (x: builtins.match ".*\\[atom].*" x.line != null) num;
      i =
        if atom != [ ] then
          (builtins.head atom).i
        else
          throw ''
            missing required `[atom]` section
             --> ${name}
          '';
      g = if l - i < 5 then num else sublist i 4 num;
    in
    throw ''
      missing required field `name`
       --> ${name}:${toString (i + 1)}:${toString ((right (builtins.elemAt lines i)) + 1)}

      ${builtins.concatStringsSep "\n" (
        map (
          x:
          let
            pad = spaces ((digits l) - (digits (x.i + 1)));
          in
          "${toString (x.i + 1)}${pad} | ${if x.i == i then "${x.line} <~~~" else x.line}"
        ) g
      )}
    '';
}
