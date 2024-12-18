/**
  Parse a string into a name and extension.

  # Examples

  ```nix
  parse "foo.bar" => { name = "foo"; ext = "bar"; }
  parse "invalid" => null
  ```

  # Type

  ```
  parse :: String -> AttrSet
  ```

  # Parameters

  - `str`: The string to parse.

  # Return Value

  An attribute set with the file `name` and an optional `ext` attribute representing the extension, if one exists.
*/

str:
let
  s = x: std.isString x || std.isPath x || x ? outPath || x ? __toString;
  l = std.length r;
  r = std.match "(\\.*[^.]+)\\.?(.+)?" (baseNameOf str);

  isnt = !s str;

  name = std.head r;
  ext = std.elemAt r 1;
  f =
    if isnt || r == null then
      throw ''
        in std.file.parse:

               expected:
                 - str: path or string representing a file name

               got:
                 - str: ${if isnt then "a ${std.typeOf str}" else str}
      ''
    else if l >= 2 && ext != null then
      { inherit name ext; }
    else
      { inherit name; };
in
std.addErrorContext "in call to std.file.parse" f
