/**
  A recursive variant of the update operator ‘//’.  The recursion
  stops when one of the attribute values is not an attribute set,
  in which case the right hand side value takes precedence over the
  left hand side value.

  # Inputs

  `lhs`

  : Left attribute set of the merge.

  `rhs`

  : Right attribute set of the merge.

  # Type

  ```
  merge :: AttrSet -> AttrSet -> AttrSet
  ```

  # Examples
  :::{.example}
  ## `lib.attrsets.merge` usage example

  ```nix
  merge {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/hda";
  } {
    boot.loader.grub.device = "";
  }

  returns: {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "";
  }
  ```

  :::
*/
lhs: rhs:
mod.mergeUntil (
  path: lhs: rhs:
  !(std.isAttrs lhs && std.isAttrs rhs)
) lhs rhs
