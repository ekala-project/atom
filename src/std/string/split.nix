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
sep: s:
let
  addContextFrom = src: target: std.substring 0 0 src + target;

  splits = std.filter std.isString (std.split (mod.escapeRegex (toString sep)) (toString s));
in
map (addContextFrom s) splits
