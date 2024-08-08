sep: str:
let
  p = builtins.split sep (toString str);
in
builtins.filter (x: builtins.typeOf x == "string") p
