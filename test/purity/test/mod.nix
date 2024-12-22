{
  Builtins = builtins == std;
  Import = import;
  ScopedImport = scopedImport;
  Fetchurl = !std ? fetchurl && __fetchurl;
  CurrentSystem = !std ? currentSystem && __currentSystem;
  CurrentTime = !std ? currentSystem && __currentTime == 0;
  NixPath = !std ? nixPath && __nixPath == [ ];
  StorePath = !std ? storePath && __storePath;
  GetEnv = !std ? getEnv && __getEnv "PATH" == "";
  GetFlake = !std ? getFlake && __getFlake;
  Std =
    let
      xs = map (x: get.stdFilter x == null) (std.attrNames std);
    in
    std.elem false xs && abort "impure functions found";
}
