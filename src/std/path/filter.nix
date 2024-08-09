/**
  Filter a directory based on a list of paths to include.

  This function creates a filtered version of a given directory, including only
  the specified paths. If the path in the list is a directory, all of its contents
  are kept.

  # Example

  ```nix
  std.path.filter [
    "list"
    "of/relative"
    "paths/to/include.c"
  ] ./some/directory/to/filter
  ```

  # Type

  ```
  path.filter :: [String] -> Path -> StorePath
  ```

  # Arguments

  - `paths`: A list of strings representing relative paths to include in the filter.
  - `path`: The path to the directory to be filtered.

  # Returns

  A filtered version of the input directory as a path, containing only the
  specified paths and their necessary parent directories.
*/

paths: path:
let
  f =
    dir:
    let
      pred = std.elem dir paths;
      next = f (dirOf dir);
    in
    dir != "." && (pred || next);

  type = std.readFileType path;
  name =
    let
      s = std.string.split "-" path;
      pred = std.match "^${std.storeDir}/.*" (toString path) == null;
    in
    if pred || std.length s < 2 then baseNameOf path else std.elemAt s 1;
in
std.path {
  inherit path name;
  filter =
    p: t:
    let
      frag = std.match "^${toString path}/(.*)" p;
      frag' = std.head frag;
      pred = if frag == null then false else std.elem frag' paths;
    in
    (t == "directory" && pred || f (dirOf frag'));
}
