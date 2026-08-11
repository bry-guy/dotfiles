---
name: explore-info
description: Use when researching or exploring information — a codebase, an external service, a monitor/dashboard, docs — and it isn't yet clear what tools or access are available.
---

# Exploring Information

## Order of operations

Before assuming something is unavailable or reaching for a workaround, check
in this order:

1. **What's already connected** — MCP plugins (`ToolSearch`), existing CLIs
   on `PATH`, project docs (README, AGENTS.md/CLAUDE.md, `justfile --list`,
   `tools/` scripts). The answer is often already sitting in the repo.
2. **What the repo's own tooling already assumes** — a script that expects
   `SOME_API_KEY` in the environment is a hint about how access is normally
   obtained, not an invitation to go source that key yourself.
3. **The narrowest read-only lookup that answers the question** — prefer
   information already committed (config, IaC, dashboards-as-code) over
   calling out to a live API, and prefer a live read-only API call over
   anything that touches auth material.

Report what you tried and what's missing rather than quietly giving up or
quietly working around it.

## Hard rule: never go looking for credentials

Do not search for, list, retrieve, decrypt, or export any credential,
secret, API key, token, session, or login/authorization material —
in AWS Secrets Manager/SSM, 1Password, env vars, config files, keychains,
or anywhere else — without asking the user first. This holds even when:

- the end goal is purely read-only,
- the credential would only be used in-memory and never printed,
- a delegated subagent would do the actual searching, not you directly.

**Why:** authorization boundaries are the user's call, not an implementation
detail to route around. Finding out mid-task that credential-hunting is
unwelcome (even when well-intentioned and read-only) means the work has to
be unwound and re-explained.

**How to apply:** if answering the question requires authenticating to
something you're not already connected to, stop and ask — e.g. "I don't
have a way to reach X yet; do you want me to look for credentials, or would
you rather log in / provide access yourself?" Installing a client/CLI so the
*user* can authenticate is fine; searching for or using credentials on their
behalf is not, absent explicit ask.
