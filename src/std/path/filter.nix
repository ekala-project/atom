paths: path:
let
  f =
    dir:
    let
      pred = builtins.elem dir paths;
      next = f (dirOf dir);
    in
    dir != "." && (pred || next);

  type = builtins.readFileType path;
  name =
    let
      s = std.string.split "-" path;
      pred = builtins.match "^${builtins.storeDir}/.*" (toString path) == null;
    in
    if pred || builtins.length s < 2 then baseNameOf path else builtins.elemAt s 1;
in
builtins.path {
  inherit path name;
  filter =
    p: t:
    let
      frag = builtins.match "^${toString path}/(.*)" p;
      frag' = builtins.head frag;
      pred = if frag == null then false else builtins.elem frag' paths;
    in
    (t == "directory" && type == "directory" && pred) || f (dirOf frag');
}
