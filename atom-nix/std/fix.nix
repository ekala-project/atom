/**
  `fix f` computes the fixed point of the given function `f`. In other words, the return value is `x` in `x = f x`.

  `f` must be a lazy function.
  This means that `x` must be a value that can be partially evaluated,
  such as an attribute set, a list, or a function.
  This way, `f` can use one part of `x` to compute another part.

  **Relation to syntactic recursion**

  This section explains `fix` by refactoring from syntactic recursion to a call of `fix` instead.

  For context, Nix lets you define attributes in terms of other attributes syntactically using the [`rec { }` syntax](https://nixos.org/manual/nix/stable/language/constructs.html#recursive-sets).

  ```nix
  nix-repl> rec {
    foo = "foo";
    bar = "bar";
    foobar = foo + bar;
  }
  { bar = "bar"; foo = "foo"; foobar = "foobar"; }
  ```

  This is convenient when constructing a value to pass to a function for example,
  but an equivalent effect can be achieved with the `let` binding syntax:

  ```nix
  nix-repl> let self = {
    foo = "foo";
    bar = "bar";
    foobar = self.foo + self.bar;
  }; in self
  { bar = "bar"; foo = "foo"; foobar = "foobar"; }
  ```

  But in general you can get more reuse out of `let` bindings by refactoring them to a function.

  ```nix
  nix-repl> f = self: {
    foo = "foo";
    bar = "bar";
    foobar = self.foo + self.bar;
  }
  ```

  This is where `fix` comes in, it contains the syntactic recursion that's not in `f` anymore.

  ```nix
  nix-repl> fix = f:
    let self = f self; in self;
  ```

  By applying `fix` we get the final result.

  ```nix
  nix-repl> fix f
  { bar = "bar"; foo = "foo"; foobar = "foobar"; }
  ```

  Such a refactored `f` using `fix` is not useful by itself.
  See [`extends`](#function-library-lib.fixedPoints.extends) for an example use case.
  There `self` is also often called `final`.

  # Inputs

  `f`

  : 1\. Function argument

  # Type

  ```
  fix :: (a -> a) -> a
  ```

  # Examples
  :::{.example}
  ## `lib.fixedPoints.fix` usage example

  ```nix
  fix (self: { foo = "foo"; bar = "bar"; foobar = self.foo + self.bar; })
  => { bar = "bar"; foo = "foo"; foobar = "foobar"; }

  fix (self: [ 1 2 (elemAt self 0 + elemAt self 1) ])
  => [ 1 2 3 ]
  ```

  :::
*/
f:
let
  x = f x;
in
x
