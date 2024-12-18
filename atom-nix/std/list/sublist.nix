/**
  Return a list consisting of at most `count` elements of `list`,
  starting at index `start`.

  # Inputs

  `start`

  : Index at which to start the sublist

  `count`

  : Number of elements to take

  `list`

  : Input list

  # Type

  ```
  sublist :: int -> int -> [a] -> [a]
  ```

  # Examples
  :::{.example}
  ## `lib.lists.sublist` usage example

  ```nix
  sublist 1 3 [ "a" "b" "c" "d" "e" ]
  => [ "b" "c" "d" ]
  sublist 1 3 [ ]
  => [ ]
  ```

  :::
*/
start: count: list:
let
  len = std.length list;
in
std.genList (n: std.elemAt list (n + start)) (
  if start >= len then
    0
  else if start + count > len then
    len - start
  else
    count
)
