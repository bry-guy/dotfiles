---
name: work-policies
description: Hard safety rules for work (Lumora) machines and repositories. Use before running commands that could touch staging/production, Kubernetes, AWS, or credentials, and before delegating such commands to subagents.
---

# Work Policies

These are hard rules, not defaults.

- Never run, or ask a subagent to run, anything with `--prod`, `--production`, `--staging`, or an env/stage/target flag naming prod or staging, unless the user explicitly instructed it in the current turn.
- `kubectl` is forbidden for you and all subagents. Use a documented `just` recipe or ask the user for the output.
- AWS access is read-only via `aws-vault exec <profile>-readonly -- aws ...` unless the user explicitly instructs otherwise. No prod-named resources.
- Never expose secrets, tokens, credentials, private keys, auth headers, or full environment dumps; redact them in any output.
