let
  l = builtins;
  imap = scopedImport { std = builtins; } ../std/list/imap.nix;
  sublist = scopedImport { std = builtins; } ../std/list/sublist.nix;
  digits = n: l.stringLength (l.toString n);
  spaces = n: toString (l.genList (x: " ") n);
  warn = l.warn or l.trace;
  right =
    str:
    let
      match = l.match "^( *)[^ ].*" str;
    in
    if match == null then
      l.stringLength str # If the string is all spaces
    else
      l.stringLength (l.head match);

in
{
  inherit warn;

  debugMsg =
    config: path:
    "in ${config.atom.id}${if config.atom ? version then "-${config.atom.version}" else ""}${
      if path == "" then "" else " at ${path}"
    }";

  context = msg: value: l.traceVerbose msg value;
  modPath =
    par: path:
    let

      modFromDir =
        path: l.concatStringsSep "." (l.tail (l.filter l.isString (l.split "/" (toString path))));
      stripParentDir =
        p: p':
        let
          len = l.stringLength (toString p);
          res = l.substring (len + 1) (-1) (toString p');
        in
        /. + res;

    in
    modFromDir (stripParentDir par path);
  import = abort "Importing arbitrary Nix files is forbidden. Declare your dependencies via the module system instead.";
  fetch = abort "Ad hoc fetching is illegal. Declare dependencies statically in the manifest instead.";
  currentSystem = abort "Accessing the current system is impure. Declare system in the manifest.";
  system = abort "`system` has been accessed and is undefined";
  time = _: warn "currentTime: Ignoring request for current time, returning: 0";
  nixPath = _: warn "nixPath: ignoring impure NIX_PATH request, returning: []";
  storePath = abort "Making explicit dependencies on store paths is illegal.";
  getEnv = _: warn "getEnv: ignoring request to access impure envvar, returning: \"\"";
  missingAtom =
    file: field:
    let
      name = toString file;
      contents = l.readFile file;
      lines = l.filter l.isString (l.split "\n" contents);
      len = l.length lines;
      num = imap (i: line: { inherit i line; }) lines;
      atom = l.filter (x: l.match "[^#]*\\[atom].*" x.line != null) num;
      i =
        if atom != [ ] then
          (l.head atom).i
        else
          throw ''
            missing required `[atom]` section
             --> ${name}
          '';
      g = if len - i < 5 then num else sublist i 4 num;
    in
    throw ''
      missing required field `${field}`
       --> ${name}:${toString (i + 1)}:${toString ((right (l.elemAt lines i)) + 1)}

      ${l.concatStringsSep "\n" (
        map (
          x:
          let
            pad = spaces ((digits len) - (digits (x.i + 1)));
          in
          "${toString (x.i + 1)}${pad} | ${if x.i == i then "${x.line} <~~~" else x.line}"
        ) g
      )}
    '';
}
