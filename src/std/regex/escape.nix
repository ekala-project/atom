/**
  Turn a string `s` into an exact regular expression

  # Inputs

  `s`
  : 1\. Function argument

  # Type

  ```
  regex.escape :: string -> string
  ```

  # Examples
  :::{.example}
  ## `lib.strings.regex.escape` usage example

  ```nix
  regex.escape "[^a-z]*"
  => "\\[\\^a-z]\\*"
  ```

  :::
*/
pre.string.escape (pre.string.chars "\\[{()^$?*+|.")
