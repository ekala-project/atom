/**
  Filter and map an attribute set by applying the given function to each attribute.

  # Examples

  ```nix
  filterMap (key: value: if key == "foo" then value else null) { foo = 1; bar = 2; }
  => { foo = 1; }

  filterMap (key: value: { ${key} = value * 2; }) { foo = 1; bar = 2; }
  => { foo = 2; bar = 4; }
  ```

  # Type

  ```
  filterMap :: (Key -> Value -> Any | Null) -> AttrSet -> AttrSet
  ```

  # Parameters

  - `f`: A function that takes an attribute name and an attribute value, and returns either a new key-value pair or a single value. If a single value is returned, the original key is preserved. If a key-value pair is returned, the new key is used, allowing for key updates. If null is returned, the item is removed from the final set.

  - `set`: The attribute set to filter and map.
*/
f: set:
std.foldl' (
  acc: key:
  let
    val = f key set.${key};
  in
  if val == null then
    acc
  else if std.isAttrs val then
    acc // val
  else
    acc // { ${key} = val; }
) { } (std.attrNames set)
