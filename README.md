# Atom: Efficient Decentralized Source Archive Format

Atom is a novel source archive format designed to make source-based builds exponentially more efficient at scale. It serves as the foundation for the Ekala ecosystem, introducing key optimizations learned from two decades of experience with Nix-style build systems.

## ⚠️ Development Status

This project is in early development with unstable APIs. While we welcome collaboration from advanced users and potential contributors, the interfaces are subject to significant changes.

## Key Features

**Smart Version Management**

- Stores versions without carrying full history
- Quick and efficient version lookups
- Minimal bandwidth usage when fetching specific versions

**Built for Decentralization**

- Unique fingerprinting system combining repository history and package names
- Self-contained identity verification without central authority
- Seamless integration with existing open-source infrastructure

**Efficient Repository Access**

- Download only the parts you need
- Bandwidth usage scales with actual requirements, not repository size
- Optimized for distributed build networks

## Components

### [atom](https://github.com/ekala-project/eka/tree/master/crates/atom)

The core Rust library implementing the Atom format specification. Currently in active development with unstable APIs.

### Elements

Language-specific integrations that implement the Atom format:

#### [atom-nix](./atom-nix)

The Nix element: a disciplined module system that enforces clear, introspectable boundaries.

- Prevents common anti-patterns in Nix codebases
- Enables static verification and optimization
- Designed for predictable, efficient evaluation
- Currently experimental with evolving interfaces

## Project Goals

Atom aims to solve fundamental inefficiencies in source-based build systems by:

- Creating clear, enforceable boundaries for code organization
- Enabling intelligent optimization through static metadata and Nix's deterministic properties
- Making version management fast and reliable in Nix's formal universe
- Scaling decentralized source distribution efficiently

For advanced users interested in contributing, please refer to the respective subdirectories for detailed technical documentation.
