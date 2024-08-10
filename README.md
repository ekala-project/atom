# Nix Module System (Atom)

> ⚠️ Warning: WIP Alpha ⚠️
>
> Aiming to deprecate or reform the NixOS module mechanism.

A lean, efficient module system for Nix that prioritizes simplicity and efficiency.

## Module Structure

A module in Atom is defined as a directory containing a `mod.nix` file. This structure allows for:

- **Modular Organization**: Each directory with a `mod.nix` file is treated as a distinct module.
- **Auto-importing**: All `.nix` files in the module directory are automatically imported as module members.
- **Nested Modules**: Subdirectories containing `mod.nix` files are treated as nested modules.
- **Public/Private Distinction**: Capitalized names in `mod.nix` denote public exports; all others are private by default.
- **Static File Access**: `mod.outPath` for non-Nix files, excluding submodules.

This approach enables clean separation of concerns, easy refactoring, and controlled access to module contents, while maintaining the ability to include necessary static files within each module's scope.

## Scoping Examples

### `mod`: Current Module

```nix
# string/mod.nix
{
  ToLower = mod.toLowerCase;
  Like = mod.like;
}

# string/toLowerCase.nix
str:
let
  head = std.substring 0 1 str;
  tail = std.substring 1 (-1) str;
in
"${mod.ToLower head}${tail}"
```

### `pre`: Parent Module Chain

```nix
# parent/mod.nix
{
  privateHelper = x: x * 2;
  PublicFunc = x: x + 1;
}

# parent/child/mod.nix
{
  UseParentPrivate = x: pre.privateHelper x;
  UseParentPublic = x: pre.PublicFunc x;
}
```

### `atom`: Top-level and Dependencies

```nix
# root/mod.nix
{
  RootFunc = x: x * 3;
}

# nested/deep/mod.nix
{
  UseRoot = x: atom.RootFunc x;
}
```

### `std`: Standard Library

```nix
# utils/mod.nix
{
  Double = x: std.mul 2 x;
  IsEven = x: std.mod x 2 == 0;
}
```

## TOML Manifest (Unstable)

> ⚠️ The manifest's structure _will_ change as the project develops.

Each atom is defined by a TOML manifest file, enhancing dependency tracking and separation of concerns:

```toml
[atom]
name = "dev"
version = "0.1.0"
description = "Development environment"

[features]
default = []

[fetch.pkgs]
name = "nixpkgs"
import = true
args = [{}]
```

### Demonstrated Components:

- Atom metadata
- Feature flags
- Legacy Nix expression fetching (e.g., nixpkgs)

Atoms are built on a theoretical language-agnostic, plugin-based schema extension mechanism. Here, `[atom]` and `[features]` are core components, while `[fetch]` represents a Nix-specific plugin feature.

Exact dependency and composition semantics are still evolving. For updates, see:

- [Compositional Semantics #19](https://github.com/ekala-project/atom/issues/19)
- [Manifest Stabilization #31](https://github.com/ekala-project/atom/issues/31)

## Usage

> ⚠️ Implementation detail: The TOML Manifest is the true entrypoint. Future CLI will respect this.

```nix
let
  atom = builtins.fetchGit "https://github.com/ekala-project/atom";
  fromManifest = import "${atom}/src/core/fromManifest.nix";
in
fromManifest {
  features = [
    # optional feature flags
  ];
} ./src/dev.toml # or specific manifest file
```

## Future CLI: `eka`

Atom is designed with a future CLI tool, tentatively named 'eka', in mind. This CLI will:

- Respect the TOML manifest
- Allow schema extension via a language-agnostic plugin interface
- Provide advanced static analysis capabilities
- Enable efficient evaluation and build processes
- Support multiple backends, with Nix being one of them
- Capitalize on the self-contained structure of Atoms.

For more details and ongoing discussions, see:

- [Efficient Build Pipelines: #20](https://github.com/ekala-project/atom/issues/20)
- [Fetching with JOSH: #25](https://github.com/ekala-project/atom/issues/25)
- [Isolated Evaluation: #27](https://github.com/ekala-project/atom/issues/27)

The research & development of 'eka' is part of our broader vision to create a more integrated, efficient, secure, and flexible development environment.
