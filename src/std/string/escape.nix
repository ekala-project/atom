/**
  Escape occurrence of the elements of `list` in `string` by
  prefixing it with a backslash.

  # Inputs

  `list`
  : 1\. Function argument

  `string`
  : 2\. Function argument

  # Type

  ```
  escape :: [string] -> string -> string
  ```

  # Examples
  :::{.example}
  ## `lib.strings.escape` usage example

  ```nix
  escape ["(" ")"] "(foo)"
  => "\\(foo\\)"
  ```

  :::
*/
list: std.replaceStrings list (map (c: "\\${c}") list)
