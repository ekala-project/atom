/**
  Create a path by combining a base path and a string.

  # Examples

  ```nix
  path.make /. "foo/bar" => /foo/bar
  path.make ./. "foo/bar" => /current/directory/foo/bar
  path.make /foo "bar/baz" => /foo/bar/baz
  path.make /foo "/bar/baz" => /foo/bar/baz
  ```

  # Type

  ```
  path.make :: Path -> String -> Path
  ```

  # Parameters

  - `base`: The base path. Use `/.` for absolute paths from root, `./.` for paths relative to the current directory, or any other path for custom base directories.
  - `str`: The string to combine with the base path.

  # Return Value

  A path combining the base path and the input string.
*/
abs: frag:
let
  s = x: std.isString x || std.isPath x || x ? outPath || x ? __toString;
  abs' = if std.isPath abs then abs else /. + abs;
  p = std.substring 0 1 frag;

  f =
    if !(s abs && s frag && !std.isPath frag) then
      throw ''
        in std.path.make:

               expected:
                 - abs: absolute path
                 - frag: string

               got:
                 - abs: ${std.typeOf abs}
                 - frag: ${std.typeOf frag}
      ''
    else if p != "/" then
      abs' + "/${frag}"
    else
      abs' + frag;
in
std.addErrorContext "in call to std.path.make" f
