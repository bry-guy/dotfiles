# Local Services

Per-machine daemons (Docker/Colima-based) that I want available locally on my dev
machines but do not run in the homelab. Defined here so they're declarative,
machine-local, and driven by `mise` tasks.

## CLI

```sh
mise run services           # list configured services
mise run services:setup     # install secret material from 1Password
mise run services:up        # docker compose up -d for all enabled services
mise run services:down      # stop services
mise run services:restart   # down + up
mise run services:status    # docker compose ps + health probe
mise run services:logs -- 1password-connect
mise run services:doctor    # preflight + remediation hints
```

All commands accept optional service names to scope to a subset, e.g.:

```sh
mise run services:up 1password-connect
```

`logs` always requires a single service name.

Underneath the tasks call:

```text
~/script/local-services <subcommand>
```

which reads:

```text
~/.config/local-services/services.toml
```

## Adding a service

1. Add an entry to `services.toml` (see schema comment at the top).
2. Drop the compose file under
   `~/.config/local-services/services/<name>/compose.yaml`.
3. If the service needs secrets that should come from 1Password, add
   `[[services.<name>.secrets]]` blocks pointing at `op://` references and
   machine-local destinations.
4. `mise run services:doctor <name>` to verify, then
   `mise run services:setup <name>` and `mise run services:up <name>`.

## Secrets posture

- Secret values are never committed.
- `services:setup` only installs material that already exists in 1Password.
- New tokens, credentials, or Connect servers must be created in 1Password.com
  first; reference them from `services.toml`.

## 1Password Connect

The default enabled service is a local 1Password Connect server, used by the
host-side `pi-ez-secret-broker`.

On first run, `mise run services:setup 1password-connect` will:

1. Use the host `op` CLI to call `op connect server create` and provision a
   Connect server in 1Password (one server per machine, named
   `local-<hostname>` by default).
2. Install the resulting credentials JSON at
   `~/.config/1password/connect/1password-credentials.json`.
3. Upload the same credentials JSON back to 1Password as a Document item
   (`1password-connect-credentials` in the `bry-guy` vault) so other machines
   can restore it. Connect does not let you re-download server credentials
   after creation, so without this step the only recovery path would be
   deleting and re-creating the server.
4. Call `op connect token create` to issue an access token, write
   `OP_CONNECT_TOKEN=...` to `~/.config/1password/connect/connect.env`, and
   store the token in a 1Password item (`OP_CONNECT_TOKEN`).

On re-run with material already present, setup is a no-op aside from the
idempotent secret-file checks. On a fresh machine where the 1Password items
already exist, setup restores from 1Password instead of provisioning new ones.

To bootstrap on a fresh machine:

```sh
op signin                                # one-time
mise run services:doctor                 # see what is missing
mise run services:setup                  # provision or restore credentials + token
mise run services:up                     # start Connect server
mise run services:status                 # confirm /heartbeat is OK
```

Then point your pi/pi-chat workers at the local Connect server. The token lives
in `~/.config/1password/connect/connect.env` and can be sourced or read by
`pi-ez-secret-broker`'s config.

Override defaults via env vars when invoking setup if you want different
names:

- `LOCAL_SERVICES_OP_CONNECT_SERVER` — Connect server title (default `local-<hostname>`)
- `LOCAL_SERVICES_OP_CONNECT_TOKEN_NAME` — Connect token title (default `<server>-token`)
- `LOCAL_SERVICES_OP_CONNECT_VAULT` — vault granted to the server (default `bry-guy`)
- `LOCAL_SERVICES_OP_CONNECT_CREDENTIALS_ITEM` — 1Password Document title used for restore
- `LOCAL_SERVICES_OP_CONNECT_TOKEN_ITEM` — 1Password Password item title for the token
