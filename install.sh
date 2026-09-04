#!/usr/bin/env sh
set -eu

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
AGENT="codex"
MODE="all"
SKIP_LOGIN=0
# Fill this value for your deployment, or pass --snippify-url / export SNIPPIFY_URL.
SNIPPIFY_URL="${SNIPPIFY_URL:-}"
SNIPPIFY_CREDENTIALS_FILE="${SNIPPIFY_CREDENTIALS_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/snippify/credentials.env}"
PUBLIC_MCP_URL="${SNIPPIFY_PUBLIC_MCP_URL:-http://127.0.0.1:8081/mcp}"
PRIVATE_MCP_URL="${SNIPPIFY_PRIVATE_MCP_URL:-http://127.0.0.1:8081/mcp}"

usage() {
  cat <<'EOF'
Install Snippify skills and MCP connections for supported agents.

Usage:
  ./install.sh [options]

Options:
  --agent codex        Agent host to configure. Only "codex" is supported now.
  --mode all           Install all skills and public/private MCP connections.
  --mode global        Alias for all.
  --mode public        Install base/public skills and public MCP only.
  --mode private       Install base/private skills and private MCP only.
  --public-url URL     Public Snippify MCP URL.
  --private-url URL    Private Snippify MCP URL.
  --snippify-url URL   Snippify API URL used for login.
  --credentials FILE   Credentials env file to write for private MCP.
  --skip-login         Do not run "snippify login" before private setup.
  -h, --help           Show this help.

Environment:
  SNIPPIFY_TOKEN            Agent Token for private MCP.
  SNIPPIFY_URL              Snippify API URL used for login.
  SNIPPIFY_CREDENTIALS_FILE Credentials env file to write.
  SNIPPIFY_PUBLIC_MCP_URL   Default public MCP URL.
  SNIPPIFY_PRIVATE_MCP_URL  Default private MCP URL.

Examples:
  ./install.sh
  ./install.sh --mode public
  SNIPPIFY_TOKEN=... ./install.sh --mode private
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run() {
  printf '+ %s\n' "$*"
  "$@"
}

quote_env_value() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

prompt_secret() {
  printf '%s' "$1" >&2
  stty -echo 2>/dev/null || true
  IFS= read -r SECRET_VALUE
  stty echo 2>/dev/null || true
  printf '\n'
  printf '%s' "$SECRET_VALUE"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --agent)
      [ "$#" -ge 2 ] || die "--agent requires a value"
      AGENT="$2"
      shift 2
      ;;
    --mode)
      [ "$#" -ge 2 ] || die "--mode requires a value"
      MODE="$2"
      shift 2
      ;;
    --public-url)
      [ "$#" -ge 2 ] || die "--public-url requires a value"
      PUBLIC_MCP_URL="$2"
      shift 2
      ;;
    --private-url)
      [ "$#" -ge 2 ] || die "--private-url requires a value"
      PRIVATE_MCP_URL="$2"
      shift 2
      ;;
    --snippify-url)
      [ "$#" -ge 2 ] || die "--snippify-url requires a value"
      SNIPPIFY_URL="$2"
      shift 2
      ;;
    --credentials)
      [ "$#" -ge 2 ] || die "--credentials requires a value"
      SNIPPIFY_CREDENTIALS_FILE="$2"
      shift 2
      ;;
    --skip-login)
      SKIP_LOGIN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

[ "$AGENT" = "codex" ] || die "Unsupported agent: $AGENT. Supported agents: codex"

case "$MODE" in
  global) MODE="all" ;;
esac

case "$MODE" in
  all|public|private) ;;
  *) die "Unsupported mode: $MODE. Use all, global, public, or private." ;;
esac

need_command npx
need_command codex

install_public_skills() {
  run npx --yes skills add "$PACKAGE_DIR" \
    --skill snippify-base \
    --skill snippify-public \
    --agent "$AGENT"
}

install_private_skills() {
  run npx --yes skills add "$PACKAGE_DIR" \
    --skill snippify-base \
    --skill snippify-private \
    --skill snippify-team \
    --agent "$AGENT"
}

configure_public_mcp() {
  if codex mcp get snippify-public >/dev/null 2>&1; then
    printf '%s\n' "Codex MCP server already exists: snippify-public"
    return
  fi

  run codex mcp add snippify-public --url "$PUBLIC_MCP_URL"
}

login_to_snippify() {
  command -v snippify >/dev/null 2>&1 || {
    printf '%s\n' "snippify CLI not found; skipping interactive login."
    return
  }

  if [ "$SNIPPIFY_URL" = "" ]; then
    die "SNIPPIFY_URL is required for private login. Fill it at the top of install.sh, export it, or pass --snippify-url."
  fi

  printf 'Snippify username: '
  IFS= read -r SNIPPIFY_USERNAME
  [ "$SNIPPIFY_USERNAME" != "" ] || die "Snippify username is required."

  SNIPPIFY_PASSWORD=$(prompt_secret 'Snippify password: ')
  [ "$SNIPPIFY_PASSWORD" != "" ] || die "Snippify password is required."

  printf '%s\n' "Starting Snippify login. This stores your Snippify API session locally."
  printf '+ SNIPPIFY_API_URL=%s snippify login\n' "$SNIPPIFY_URL"
  if ! printf '%s\n%s\n' "$SNIPPIFY_USERNAME" "$SNIPPIFY_PASSWORD" | SNIPPIFY_API_URL="$SNIPPIFY_URL" snippify login; then
    unset SNIPPIFY_PASSWORD
    die "snippify login failed."
  fi

  unset SNIPPIFY_PASSWORD
}

write_credentials_file() {
  CREDENTIALS_DIR=$(dirname -- "$SNIPPIFY_CREDENTIALS_FILE")
  mkdir -p "$CREDENTIALS_DIR"
  chmod 700 "$CREDENTIALS_DIR" 2>/dev/null || true

  umask 077
  {
    printf 'export SNIPPIFY_URL=%s\n' "$(quote_env_value "$SNIPPIFY_URL")"
    if [ "${SNIPPIFY_USERNAME:-}" != "" ]; then
      printf 'export SNIPPIFY_USERNAME=%s\n' "$(quote_env_value "$SNIPPIFY_USERNAME")"
    fi
    printf 'export SNIPPIFY_TOKEN=%s\n' "$(quote_env_value "$SNIPPIFY_TOKEN")"
  } > "$SNIPPIFY_CREDENTIALS_FILE"
  chmod 600 "$SNIPPIFY_CREDENTIALS_FILE" 2>/dev/null || true

  printf 'Wrote private MCP credentials to %s\n' "$SNIPPIFY_CREDENTIALS_FILE"
}

configure_private_mcp() {
  if [ "$SKIP_LOGIN" -eq 0 ]; then
    login_to_snippify
  fi

  if [ "${SNIPPIFY_TOKEN:-}" = "" ]; then
    printf '%s\n' "Private MCP requires a Snippify Agent Token with artifact:read and artifact:create scopes."
    SNIPPIFY_TOKEN=$(prompt_secret 'Snippify Agent Token: ')
    export SNIPPIFY_TOKEN
  fi

  [ "${SNIPPIFY_TOKEN:-}" != "" ] || die "SNIPPIFY_TOKEN is required for private MCP setup."
  write_credentials_file

  if codex mcp get snippify-private >/dev/null 2>&1; then
    printf '%s\n' "Codex MCP server already exists: snippify-private"
    return
  fi

  run codex mcp add snippify-private \
    --url "$PRIVATE_MCP_URL" \
    --bearer-token-env-var SNIPPIFY_TOKEN
}

case "$MODE" in
  all)
    install_public_skills
    install_private_skills
    configure_public_mcp
    configure_private_mcp
    ;;
  public)
    install_public_skills
    configure_public_mcp
    ;;
  private)
    install_private_skills
    configure_private_mcp
    ;;
esac

printf '%s\n' "Verifying Codex MCP configuration..."
run codex mcp list

case "$MODE" in
  all|public) run codex mcp get snippify-public ;;
esac

case "$MODE" in
  all|private) run codex mcp get snippify-private ;;
esac

cat <<'EOF'

Snippify skills and MCP connections are installed for Codex.

For private actions, start Codex from a shell where SNIPPIFY_TOKEN is set:
  export SNIPPIFY_TOKEN
  codex
EOF
