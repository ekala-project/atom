# What is Atom?

Atom is a module system for Nix that transforms how we structure, share, and maintain Nix-based projects. It builds upon Nix's strengths to create a framework for truly modular, self-contained units of code.

## Core Principles

1. **Lazy Purity**: Extends Nix's lazy evaluation to file copying, ensuring efficiency without compromising purity.
2. **True Modularity**: Self-contained units with clear boundaries and explicit interfaces.
3. **Flexible Composition**: Free composition of Atoms, allowing versatile project structures.
4. **Enhanced Sharing**: Private module member semantics for better encapsulation and safer code sharing.
5. **Performance-Driven**: Engineered for efficiency, avoiding overhead common in other Nix modularity systems.
6. **Focused Functionality**: Dedicated solely to being an excellent module system, excelling in its core purpose without feature bloat.

## How Atom Transforms Nix Development

1. **Efficient Resource Usage**: Copies files to the Nix store only when needed, reducing data transfer and storage.
2. **Improved Code Organization**: Encourages cleaner, more maintainable code structures.
3. **Enhanced Tooling Support**: Enables powerful static analysis and introspection without full Nix evaluation.
4. **Simplified Dependency Management**: Offers granular control, reducing bloat and improving clarity.
5. **Consistent Semantics**: Provides higher-level abstractions over Nix's low-level constructs, allowing developers to focus on code logic rather than Nix implementation details.

## Who Benefits from Atom?

- **Nix Beginners**: Lower entry barrier through clearer structure and improved tooling.
- **Experienced Developers**: Enhanced modularity and efficiency for complex projects.
- **Teams**: Improved code sharing and collaboration via well-defined module boundaries.
- **NixOS Configuration Managers**: Simplified management of complex system configurations.
- **Library Authors**: Easier creation and maintenance of reusable Nix code.

## Atom vs. Traditional Nix Approaches

| Feature                 | Traditional Nix | Flakes  | Atom |
| ----------------------- | --------------- | ------- | ---- |
| Lazy Evaluation         | ✓               | ✓       | ✓    |
| Lazy File Copying       | ✓               | ✗       | ✓    |
| Explicit Dependencies   | ✗               | ✓       | ✓    |
| Private Module Members  | ✗               | ✗       | ✓    |
| Static Analyzability    | ✗               | Partial | ✓    |
| Unopinionated Structure | ✓               | Partial | ✓    |

## Next Steps

Explore Atom's core concepts:

- [Atoms and Modules](./atoms-and-modules.md)
- [Lazy Evaluation and Purity](./lazy-evaluation-and-purity.md)
- [Dependency Management](./dependency-management.md)
