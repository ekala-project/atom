let
  l = builtins;
in
{
  /**
    Resolve feature dependencies for Atom's module composer.

    This function takes a set of features and their dependencies, and an initial list of features.
    It returns a list of all required features, including dependencies, without duplicates.

    # Examples

    Given a TOML file with feature declarations:

    ```toml
    [features]
    default = ["foo", "bar"]
    foo = ["baz"]
    bar = ["qux"]
    baz = []
    qux = ["baz"]
    ```

    Nix usage:

    ```nix
    features.resolve featureSet ["foo", "bar"] => ["foo", "baz", "bar", "qux"]
    ```

    # Type

    ```
    features.resolve :: AttrSet -> [String] -> [String]
    ```

    # Parameters

    - `featureSet`: An attribute set where keys are feature names and values are lists of dependencies.
    - `initials`: A list of initially requested features.

    # Return Value

    A list of strings representing all required features, including dependencies, without duplicates.

    # Notes

    - The function handles circular dependencies.
    - The order of features in the output list is not guaranteed.
    - Features not present in the `featureSet` are ignored.
  */
  resolve =
    featureSet: initials:
    let
      resolve =
        features: acc:
        let
          features' = l.filter (f: !(acc ? ${f})) features;
          acc' = l.foldl' (a: f: a // { ${f} = null; }) acc features';
        in
        if features' == [ ] then acc' else resolve (l.concatMap (f: featureSet.${f} or [ ]) features') acc';

      resolved = resolve initials { };
    in
    l.attrNames resolved;
}
