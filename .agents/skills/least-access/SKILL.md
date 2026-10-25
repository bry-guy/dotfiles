---
name: least-access
description: Use the least-privileged role and credential that covers the task. Use before running anything that loads secrets, deploys, or touches databases, clusters, cloud accounts, DNS, VPN/tailnet, or production data, and whenever a repo's AGENTS.md has a Roles section.
---

# Least access

A role is a named bundle of credentials, such as `operator`, `developer`, or `admin`.
Repos declare theirs in a `## Roles` section of `AGENTS.md`. The section covers the
role names, how a role is selected, and which tasks need which role.

- Find the repo's roles before acting. Pick the lowest role whose tasks cover the
  work: operator (check, inspect, plan, backup) < developer (apply, build, deploy) < admin.
- Your shell may already have a role selected, for example `AGENT_ROLE` set by `.envrc`.
  Stay in it. If a task fails for lack of access, don't switch roles to get past it.
- Never reach for a stronger credential yourself: don't read another role's Keychain
  item, vault, token file, kubeconfig, or SSH key, and don't edit `.envrc` or role
  config to raise your access. On a single Unix user these are reachable anyway;
  using them is a violation, not a workaround.
- Admin tasks: stop, print the exact command with one line on why, and wait for the
  user's approval in the current turn. Approval covers that one command.
- "Keep going", "clean up", or approving a plan is not approval of an admin action.
  Admin actions include: deleting or rebuilding vaults/items, creating credentials or
  service accounts, commands using an admin kubeconfig or context, `*:apply` tasks that
  write Secrets/IAM/policy, `tofu apply` on admin stacks, and pushing to a protected branch.
  A Touch ID or 1Password prompt is not approval: the user can't see what it's for.
- If your role can't do something it should, stop and report the missing task,
  credential, or permission. Don't improvise a way around it with ad-hoc DB writes,
  `kubectl`, or raw API calls.
- Prefer read-only forms first: plan, check, dry-run, `READ ONLY` transactions.
- Never print secrets. Check presence, length, fingerprint, or hash instead.
- If the repo declares no roles, use the weakest credential that works (read-only
  profiles, plan before apply). Ask before anything destructive, anything that
  creates a credential, or any write to production.
- Subagents get your role and these rules; never a stronger role.
