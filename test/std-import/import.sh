#!/usr/bin/env bash

set -ex

# defaults
f="$(nix eval -f import.nix default.parsedFeatures)"
[[ "$f" == '[ "core" "std" ]' ]]
f="$(nix eval -f import.nix default.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix default.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix default.sanity)"
[[ "$f" == true ]]

# explicit
f="$(nix eval -f import.nix explicit.parsedFeatures)"
[[ "$f" == '[ "core" "std" ]' ]]
f="$(nix eval -f import.nix explicit.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix explicit.lib)"
[[ "$f" == false ]]

# no std set
f="$(nix eval -f import.nix noStd.parsedFeatures)"
[[ "$f" == '[ "core" ]' ]]
f="$(nix eval -f import.nix noStd.std)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.lib)"
[[ "$f" == false ]]

# no std set
f="$(nix eval -f import.nix withPkgLib.parsedFeatures)"
[[ "$f" == '[ "core" "pkg_lib" "std" ]' ]]
f="$(nix eval -f import.nix withPkgLib.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withPkgLib.lib)"
[[ "$f" == true ]]
