#!/usr/bin/env sh
set -eu

SKILLS_SOURCE="https://github.com/Snippify/skills"
PUBLIC_URL="${SNIPPIFY_PUBLIC_MCP_URL:-http://127.0.0.1:8081/mcp}"
AUTHENTICATED_URL="${SNIPPIFY_AUTHENTICATED_MCP_URL:-$PUBLIC_URL}"
CREDENTIALS_FILE="${SNIPPIFY_CREDENTIALS_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/snippify/credentials.env}"

usage() {
  cat <<'EOF'
Install Snippify skills and Codex MCP connections.

Usage: ./install.sh [options]

Options:
  --public-url URL         Public MCP endpoint.
  --authenticated-url URL  Authenticated MCP endpoint (defaults to the public endpoint).
  --credentials FILE       Where to save SNIPPIFY_TOKEN for Codex.
  -h, --help               Show this help.

The installer securely reads SNIPPIFY_TOKEN from standard input. Press Enter
to configure only public skills and the public MCP connection.
EOF
}

die() { printf '%s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }

replace_mcp() {
  name=$1
  shift
  if codex mcp get "$name" >/dev/null 2>&1; then codex mcp remove "$name"; fi
  codex mcp add "$name" "$@"
}

read_token() {
  printf 'Snippify access token (press Enter for public-only setup): ' >&2
  if [ -t 0 ]; then stty -echo; fi
  IFS= read -r SNIPPIFY_TOKEN || SNIPPIFY_TOKEN=''
  if [ -t 0 ]; then stty echo; printf '\n' >&2; fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --public-url) [ "$#" -gt 1 ] || die "--public-url requires a value"; PUBLIC_URL=$2; shift 2 ;;
    --authenticated-url) [ "$#" -gt 1 ] || die "--authenticated-url requires a value"; AUTHENTICATED_URL=$2; shift 2 ;;
    --credentials) [ "$#" -gt 1 ] || die "--credentials requires a value"; CREDENTIALS_FILE=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

read_token

need npx
need codex

if [ -n "$SNIPPIFY_TOKEN" ]; then
  npx --yes skills add "$SKILLS_SOURCE" --skill snippify-base --skill snippify-public --skill snippify-contribute --agent codex
else
  npx --yes skills add "$SKILLS_SOURCE" --skill snippify-base --skill snippify-public --agent codex
fi

replace_mcp snippify-public --url "$PUBLIC_URL"

if [ -n "$SNIPPIFY_TOKEN" ]; then
  credentials_dir=$(dirname "$CREDENTIALS_FILE")
  umask 077
  mkdir -p "$credentials_dir"
  printf 'export SNIPPIFY_TOKEN=%s\n' "$(printf '%s' "$SNIPPIFY_TOKEN" | sed "s/'/'\\\\''/g; s/^/'/; s/$/'/")" > "$CREDENTIALS_FILE"
  chmod 600 "$CREDENTIALS_FILE"
  replace_mcp snippify-authenticated --url "$AUTHENTICATED_URL" --bearer-token-env-var SNIPPIFY_TOKEN
  printf 'Installed authenticated Snippify support. Start Codex after: . %s\n' "$CREDENTIALS_FILE"
else
  printf '%s\n' 'Installed public Snippify support. Run the installer again and enter a token for authenticated support.'
fi
