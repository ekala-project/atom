/**
  Conditionally returns an attribute set based on the value of the `_if` attribute.

  # Examples

  ```nix
  when { _if = true; foo = "bar"; } => { foo = "bar"; }
  when { _if = false; foo = "bar"; } => { }
  ```

  # Type

  ```
  when :: AttrSet -> AttrSet
  ```

  # Parameters

  - `set`: The attribute set to conditionally return.

  # Return Value

  If the `_if` attribute of the input set is `true` or missing, returns the input set with the `_if` attribute removed. Otherwise, returns an empty attribute set.
*/
set: if set._if or true then std.removeAttrs set [ "_if" ] else { }
