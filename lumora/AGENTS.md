# Agent Notes

- Invariant: agents may connect only to local databases on this machine for this repo's development workflows. Never connect to any non-local database, remote database, staging database, production database, or any database/service outside local development.
- Invariant: agents may never connect to the aws prod environment. staging and sandbox environment are acceptable.
- Invariant: agents making non-local changes (e.g., changing an aws resource) must ask permission before making any changes. reads are ok.
- Invariant: agents must ask permission before editing files while on `main` branch.
- Invariant: for DX tooling work, agents may read from AWS S3 (staging/sandbox only) but must never write to S3 or modify any AWS resources without explicit permission.
- Invariant: agents must never connect to or reference production databases, production S3 buckets, or production API endpoints in any configuration files, scripts, or code they produce.
- Invariant: tasks within a repo must not cross repo boundaries or compose horizontally. A repo may check for a dependency (e.g., "wattsonic jar exists") and error if missing, but must not build, fetch, or manage artifacts from peer repos. Cross-repo composition belongs in a parent directory (e.g., ~/lumora) via a top-level justfile or similar orchestrator.
- Invariant: agents must use `just` commands (from justfile/justfile.local) for building, testing, running services, and other dev workflows instead of invoking Gradle, pnpm, or other tools directly. Run `just --list` to see available recipes.
- Invariant: machine-local tool activation may wrap `just`, but `just` must never invoke machine-local tool activation. `justfile` / `justfile.local` recipes must call underlying tools directly and assume the required tools are already on `PATH`. If a workflow needs local tool activation or AWS credential wrapping, invoke that wrapper outside `just` and have it run the relevant `just` command.
- Invariant: machine-local tool configuration is local-only and must not be committed to product repos or documented as a project requirement.
