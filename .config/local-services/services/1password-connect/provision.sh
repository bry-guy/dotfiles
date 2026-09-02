#!/usr/bin/env bash
# Provision a local 1Password Connect server using the host `op` CLI.
#
# Invoked by `~/script/local-services setup` when the required secret material
# is missing. Idempotent: re-running this script with existing material is a
# no-op aside from issuing a fresh token if `connect.env` is missing.
#
# Side-effects on first run (when local material is absent):
#   1. `op connect server create` provisions a Connect server in 1Password
#      and downloads the credentials JSON to a temp dir.
#   2. The credentials JSON is installed to ~/.config/1password/connect/...
#   3. The credentials JSON is uploaded back to 1Password as a Document item
#      so other machines can re-download it (Connect does not let you
#      re-download server credentials after creation).
#   4. `op connect token create` issues a token, writes the token env file,
#      and stores the token as a Password item so other machines can read it.
#
# Environment overrides:
#   LOCAL_SERVICES_OP_CONNECT_SERVER       Connect server name. Default: local-<hostname>
#   LOCAL_SERVICES_OP_CONNECT_TOKEN_NAME   Connect token name. Default: <server>-token
#   LOCAL_SERVICES_OP_CONNECT_VAULT        Vault to grant the server access to. Default: bry-guy
#   LOCAL_SERVICES_OP_CONNECT_CREDENTIALS_ITEM   1Password Document title. Default: 1password-connect-credentials
#   LOCAL_SERVICES_OP_CONNECT_TOKEN_ITEM   1Password Password item title. Default: OP_CONNECT_TOKEN

set -euo pipefail

CREDENTIALS_DEST="${HOME}/.config/1password/connect/1password-credentials.json"
TOKEN_ENV_FILE="${HOME}/.config/1password/connect/connect.env"
TOKEN_ENV_VAR="OP_CONNECT_TOKEN"

server_default="local-$(hostname -s | tr '[:upper:]' '[:lower:]')"
SERVER_NAME="${LOCAL_SERVICES_OP_CONNECT_SERVER:-$server_default}"
TOKEN_NAME="${LOCAL_SERVICES_OP_CONNECT_TOKEN_NAME:-${SERVER_NAME}-token}"
VAULT_GRANT="${LOCAL_SERVICES_OP_CONNECT_VAULT:-bry-guy}"
CREDENTIALS_ITEM="${LOCAL_SERVICES_OP_CONNECT_CREDENTIALS_ITEM:-1password-connect-credentials}"
TOKEN_ITEM="${LOCAL_SERVICES_OP_CONNECT_TOKEN_ITEM:-OP_CONNECT_TOKEN}"

if ! command -v op >/dev/null 2>&1; then
    echo "1Password CLI (op) is not on PATH" >&2
    exit 1
fi
if ! op account list >/dev/null 2>&1; then
    echo "1Password CLI is not signed in. Run \`op signin\` first." >&2
    exit 1
fi

mkdir -p "$(dirname "$CREDENTIALS_DEST")" "$(dirname "$TOKEN_ENV_FILE")"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

restore_credentials_from_op() {
    if op item get "$CREDENTIALS_ITEM" --vault "$VAULT_GRANT" >/dev/null 2>&1; then
        echo "[1password-connect] restoring credentials JSON from 1Password item '$CREDENTIALS_ITEM'..."
        op read "op://${VAULT_GRANT}/${CREDENTIALS_ITEM}/credentials.json" > "$workdir/restore.json"
        install -m 0600 "$workdir/restore.json" "$CREDENTIALS_DEST"
        return 0
    fi
    return 1
}

upload_credentials_to_op() {
    if op item get "$CREDENTIALS_ITEM" --vault "$VAULT_GRANT" >/dev/null 2>&1; then
        return 0
    fi
    echo "[1password-connect] uploading credentials JSON to 1Password as document '$CREDENTIALS_ITEM'..."
    op document create "$CREDENTIALS_DEST" \
        --title "$CREDENTIALS_ITEM" \
        --file-name credentials.json \
        --vault "$VAULT_GRANT" >/dev/null
}

restore_token_from_op() {
    if op item get "$TOKEN_ITEM" --vault "$VAULT_GRANT" >/dev/null 2>&1; then
        echo "[1password-connect] restoring Connect token from 1Password item '$TOKEN_ITEM'..."
        token_value="$(op read "op://${VAULT_GRANT}/${TOKEN_ITEM}/credential")"
        if [ -n "$token_value" ]; then
            umask 077
            printf '%s=%s\n' "$TOKEN_ENV_VAR" "$token_value" > "$TOKEN_ENV_FILE"
            chmod 0600 "$TOKEN_ENV_FILE"
            return 0
        fi
    fi
    return 1
}

upload_token_to_op() {
    local token_value="$1"
    if op item get "$TOKEN_ITEM" --vault "$VAULT_GRANT" >/dev/null 2>&1; then
        return 0
    fi
    echo "[1password-connect] storing Connect token in 1Password item '$TOKEN_ITEM'..."
    op item create \
        --category password \
        --title "$TOKEN_ITEM" \
        --vault "$VAULT_GRANT" \
        "credential[password]=$token_value" >/dev/null
}

if [ ! -s "$CREDENTIALS_DEST" ]; then
    if ! restore_credentials_from_op; then
        if op connect server get "$SERVER_NAME" >/dev/null 2>&1; then
            cat >&2 <<EOF
Connect server '$SERVER_NAME' already exists in 1Password but neither
'$CREDENTIALS_DEST' nor the 1Password document '$CREDENTIALS_ITEM' is available.
1Password does not let you re-download an existing Connect server's credentials,
so recovery requires either restoring the credentials JSON from another machine
or deleting and re-provisioning the server:

  op connect server delete '$SERVER_NAME'
  mise run services:setup 1password-connect

Refusing to proceed automatically.
EOF
            exit 1
        fi
        echo "[1password-connect] creating Connect server '$SERVER_NAME' with access to vault '$VAULT_GRANT'..."
        (cd "$workdir" && op connect server create "$SERVER_NAME" --vaults "$VAULT_GRANT" --force >/dev/null)
        install -m 0600 "$workdir/1password-credentials.json" "$CREDENTIALS_DEST"
    fi
fi

upload_credentials_to_op

if [ ! -s "$TOKEN_ENV_FILE" ]; then
    if ! restore_token_from_op; then
        echo "[1password-connect] issuing Connect token '$TOKEN_NAME' for server '$SERVER_NAME'..."
        token="$(op connect token create "$TOKEN_NAME" --server "$SERVER_NAME" --vault "$VAULT_GRANT" | tail -n1)"
        umask 077
        printf '%s=%s\n' "$TOKEN_ENV_VAR" "$token" > "$TOKEN_ENV_FILE"
        chmod 0600 "$TOKEN_ENV_FILE"
        upload_token_to_op "$token"
    fi
fi

echo "[1password-connect] provision complete"
echo "  credentials: $CREDENTIALS_DEST"
echo "  token env:   $TOKEN_ENV_FILE"
