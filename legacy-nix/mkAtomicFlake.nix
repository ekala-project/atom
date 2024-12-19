{
  manifest,
  noSystemManifest ? null,
  perSystemNames ? [
    "checks"
    "packages"
    "apps"
    "formatter"
    "devShells"
    "hydraJobs"
  ],
  systems ? [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ],
}:

let
  npinsSrcs = import ../src/npins;
  lib = import (npinsSrcs."nixpkgs.lib" + "/lib");
  l = lib // builtins;

  importAtom = import ../src/core/importAtom.nix;

  noSystemAtom = importAtom { } noSystemManifest;

  verifyNoSystem =
    atomManifest:
    let
      atomConfig = l.fromTOML (l.readFile atomManifest);
      features = atomConfig.features.default or [ ];
      hasSystemFeature = l.elem "system" features;
    in
    !hasSystemFeature;

  hasNoSystemAtom = noSystemManifest != null && verifyNoSystem noSystemManifest;

  optionalNoSystemAtom = if hasNoSystemAtom then noSystemAtom else { };

  transformedAtomFromSystem =
    system:
    let
      evaluatedAtom = importAtom { inherit system; } manifest;
      # perSystemAtomAttributes = l.getAttrs perSystemNames evaluatedAtom;
      mkPerSystemValue = _: value: { ${system} = value; };
    in
    l.mapAttrs mkPerSystemValue evaluatedAtom;

  accumulate = accumulator: set: accumulator // set;
  combineSets = _: sets: l.foldl' accumulate { } sets;

  transformedAtoms = l.map transformedAtomFromSystem systems;

  combinedPerSystemAttributes = l.zipAttrsWith combineSets transformedAtoms;

in
optionalNoSystemAtom // combinedPerSystemAttributes
