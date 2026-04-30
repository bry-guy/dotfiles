# Global Pi Agent Notes

- Prefer project-local instructions from `AGENTS.md` / `CLAUDE.md` files closer to the working directory when they are more specific.
- Use the repository's documented workflow commands instead of invoking lower-level build/test tools directly. In Lumora repos, use `just` recipes and run `just --list` to discover them.
- Invariant: machine-local tool activation may wrap project workflow commands, but project workflow commands must not invoke machine-local tool activation.
  - Local environment/tool managers may run `just`.
  - `justfile` / `justfile.local` recipes must call underlying tools directly and assume required tools are already on `PATH`.
  - AWS credential wrappers belong outside `just` unless the project explicitly documents otherwise.
- Ask for permission before installing tools or changing machine-global configuration.
- Keep machine-local tool configuration local-only unless the user explicitly asks to commit it.
