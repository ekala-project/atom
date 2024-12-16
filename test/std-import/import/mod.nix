let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  CoreF = cfg.features.resolved.core;
  StdF = cfg.features.resolved.std;
  Sanity = scope.std.__internal.__isStd__;
}
