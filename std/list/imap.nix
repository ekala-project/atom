/**
  Map with index starting from 0

  # Inputs

  `f`

  : 1\. Function argument

  `list`

  : 2\. Function argument

  # Type

  ```
  imap :: (int -> a -> b) -> [a] -> [b]
  ```

  # Examples
  :::{.example}
  ## `lib.lists.imap` usage example

  ```nix
  imap (i: v: "${v}-${toString i}") ["a" "b"]
  => [ "a-0" "b-1" ]
  ```

  :::
*/
f: list: std.genList (n: f n (std.elemAt list n)) (std.length list)
