{
  upperChars = mod.stringToChars "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  lowerChars = mod.stringToChars "abcdefghijklmnopqrstuvwxyz";

  stringToChars = s: std.genList (p: std.substring p 1 s) (std.stringLength s);

  /**
    Convert a string to lowercase by replacing all uppercase characters with their lowercase equivalents.

    # Examples

    ```nix
    ToLower "FOO" => "foo"
    ToLower "Hello World" => "hello world"
    ```

    # Type

    ```
    toLowerCase :: String -> String
    ```

    # Parameters

    - `str`: The string to convert.

    # Return Value

    The input string with all uppercase characters converted to lowercase.
  */
  ToLower = std.replaceStrings mod.upperChars mod.lowerChars;

  ToLowerCase = mod.toLowerCase;
}
