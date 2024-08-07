let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  ResolvedFeatures = __atom.features.__resolved;
  Sanity = scope.std.__internal.__isStd__;
}
