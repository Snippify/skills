#!/usr/bin/env sh
set -eu

SKILLS_SOURCE="https://github.com/Snippify/skills"
MODE="all"
PUBLIC_URL="${SNIPPIFY_PUBLIC_MCP_URL:-http://127.0.0.1:8081/mcp}"
AUTHENTICATED_URL="${SNIPPIFY_AUTHENTICATED_MCP_URL:-$PUBLIC_URL}"
CREDENTIALS_FILE="${SNIPPIFY_CREDENTIALS_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/snippify/credentials.env}"

usage() {
  cat <<'EOF'
Install Snippify skills and Codex MCP connections.

Usage: ./install.sh [options]

Options:
  --mode MODE              Install all, public, or authenticated support.
  --skip-login             Accepted for curl installer compatibility.
  --public-url URL         Public MCP endpoint.
  --authenticated-url URL  Authenticated MCP endpoint (defaults to the public endpoint).
  --credentials FILE       Where to save SNIPPIFY_TOKEN for Codex.
  -h, --help               Show this help.

For authenticated setup:
  export SNIPPIFY_TOKEN='PASTE_YOUR_TOKEN_HERE'
  curl -fsSL https://raw.githubusercontent.com/Snippify/skills/main/install.sh \
    | bash -s -- --mode authenticated --skip-login
  . ~/.config/snippify/credentials.env
  codex
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
  if [ "$MODE" = "public" ]; then SNIPPIFY_TOKEN=''; return; fi
  if [ -n "${SNIPPIFY_TOKEN:-}" ]; then return; fi
  if [ ! -t 0 ]; then
    [ "$MODE" != "authenticated" ] || die "SNIPPIFY_TOKEN must be exported before authenticated installation."
    SNIPPIFY_TOKEN=''
    return
  fi
  printf 'Snippify access token (press Enter for public-only setup): ' >&2
  stty -echo
  IFS= read -r SNIPPIFY_TOKEN || SNIPPIFY_TOKEN=''
  stty echo
  printf '\n' >&2
  [ "$MODE" != "authenticated" ] || [ -n "$SNIPPIFY_TOKEN" ] || die "SNIPPIFY_TOKEN is required for authenticated installation."
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode) [ "$#" -gt 1 ] || die "--mode requires a value"; MODE=$2; shift 2 ;;
    --skip-login) shift ;;
    --public-url) [ "$#" -gt 1 ] || die "--public-url requires a value"; PUBLIC_URL=$2; shift 2 ;;
    --authenticated-url) [ "$#" -gt 1 ] || die "--authenticated-url requires a value"; AUTHENTICATED_URL=$2; shift 2 ;;
    --credentials) [ "$#" -gt 1 ] || die "--credentials requires a value"; CREDENTIALS_FILE=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

case "$MODE" in all|public|authenticated) ;; *) die "Unsupported mode: $MODE" ;; esac

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
  if codex mcp get snippify-authenticated >/dev/null 2>&1; then codex mcp remove snippify-authenticated; fi
  printf '%s\n' 'Installed public Snippify support. Run the installer again and enter a token for authenticated support.'
fi
