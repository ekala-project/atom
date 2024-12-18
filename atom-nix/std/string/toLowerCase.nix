/**
  Convert a string to lowercase.

  # Examples

  ```
  toLowerCase "FOO" => "fOO"
  ```

  # Type

  ```
  toLowerCase :: String -> String
  ```

  # Parameters

  - `str`: The string to convert.

  # Return Value

  The input string with the first character converted to lowercase.

  # Note
  This function only converts the first character of the string to lowercase, leaving the rest of the string unchanged. If you need to convert the entire string to lowercase, use the `toLower` function instead.
*/
str:
let
  head = std.substring 0 1 str;
  tail = std.substring 1 (-1) str;
in
"${mod.toLower or mod.ToLower head}${tail}"
