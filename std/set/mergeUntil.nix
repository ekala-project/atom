/**
  Does the same as the update operator '//' except that attributes are
  merged until the given predicate is verified.  The predicate should
  accept 3 arguments which are the path to reach the attribute, a part of
  the first attribute set and a part of the second attribute set.  When
  the predicate is satisfied, the value of the first attribute set is
  replaced by the value of the second attribute set.

  # Inputs

  `pred`

  : Predicate, taking the path to the current attribute as a list of strings for attribute names, and the two values at that path from the original arguments.

  `lhs`

  : Left attribute set of the merge.

  `rhs`

  : Right attribute set of the merge.

  # Type

  ```
  mergeUntil :: ( [ String ] -> AttrSet -> AttrSet -> Bool ) -> AttrSet -> AttrSet -> AttrSet
  ```

  # Examples
  :::{.example}
  ## `lib.attrsets.mergeUntil` usage example

  ```nix
  mergeUntil (path: l: r: path == ["foo"]) {
    # first attribute set
    foo.bar = 1;
    foo.baz = 2;
    bar = 3;
  } {
    #second attribute set
    foo.bar = 1;
    foo.quz = 2;
    baz = 4;
  }

  => {
    foo.bar = 1; # 'foo.*' from the second set
    foo.quz = 2; #
    bar = 3;     # 'bar' from the first set
    baz = 4;     # 'baz' from the second set
  }
  ```

  :::
*/

pred: lhs: rhs:
let
  f =
    attrPath:
    std.zipAttrsWith (
      n: values:
      let
        here = attrPath ++ [ n ];
      in
      if std.length values == 1 || pred here (std.elemAt values 1) (std.head values) then
        std.head values
      else
        f here values
    );
in
f [ ] [
  rhs
  lhs
]
