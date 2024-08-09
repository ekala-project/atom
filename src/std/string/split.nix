/**
  Cut a string with a separator and produces a list of strings which
  were separated by this separator.

  # Inputs

  `sep`
  : 1\. Function argument

  `s`
  : 2\. Function argument

  # Type

  ```
  string.split :: string -> string -> [string]
  ```

  # Examples
  :::{.example}
  ## `string.split` usage example

  ```nix
  string.split "." "foo.bar.baz"
  => [ "foo" "bar" "baz" ]
  string.split "/" "/usr/local/bin"
  => [ "" "usr" "local" "bin" ]
  ```

  :::
*/
sep: str:
let
  p = std.split (pre.regex.escape (toString sep)) (toString str);
in
std.filter (x: std.typeOf x == "string" && x != "") p
