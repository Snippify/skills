# Snippify Skills and Codex setup

Run these commands from the Snippify repository root. The URLs are the current local defaults; start the Snippify API and Streamable HTTP MCP service before connecting Codex.

## Quick setup

```bash
npx skills add . \
  --skill snippify-base \
  --skill snippify-private \
  --skill snippify-public \
  --skill snippify-team \
  --agent codex

snippify create-sample-user
snippify login

codex mcp add snippify-public \
  --url http://127.0.0.1:8081/mcp

printf 'Snippify Agent Token: '
IFS= read -r -s SNIPPIFY_TOKEN
printf '\n'
export SNIPPIFY_TOKEN
codex mcp add snippify-private \
  --url http://127.0.0.1:8081/mcp \
  --bearer-token-env-var SNIPPIFY_TOKEN

codex mcp list
codex mcp get snippify-public
codex mcp get snippify-private
codex
```

Copy the one-time `token` printed by `snippify create-sample-user` into the hidden prompt. Do not commit or paste it into Codex configuration.

## Install Skills

Install all four Skills for Codex from this checkout:

```bash
npx skills add . \
  --skill snippify-base \
  --skill snippify-private \
  --skill snippify-public \
  --skill snippify-team \
  --agent codex
```

## Login

```bash
snippify login
```

This interactively prompts for email and password, calls the API configured by `SNIPPIFY_API_URL` (default `http://127.0.0.1:8080`), and stores the returned access and refresh credentials in the user's Snippify config directory with restricted permissions.

Login does not currently produce the Agent Token required by private MCP. Its access token has the `api:access` scope, while the private MCP tools require `artifact:read` or `artifact:create`.

## Add public MCP

The public tools are anonymous:

```bash
codex mcp add snippify-public \
  --url http://127.0.0.1:8081/mcp
```

## Add private MCP

The private server uses Streamable HTTP on the same endpoint and authenticates every protected request with a Bearer Agent Token. For the current local development flow, create that token once:

```bash
snippify create-sample-user
```

Copy the returned `token`, then keep it in the existing `SNIPPIFY_TOKEN` shell variable for Codex:

```bash
printf 'Snippify Agent Token: '
IFS= read -r -s SNIPPIFY_TOKEN
printf '\n'
export SNIPPIFY_TOKEN

codex mcp add snippify-private \
  --url http://127.0.0.1:8081/mcp \
  --bearer-token-env-var SNIPPIFY_TOKEN
```

Start Codex from a shell where `SNIPPIFY_TOKEN` is set. Codex reads it at runtime and sends it as `Authorization: Bearer <token>`.

## Team skill

`snippify-team` is installable now, but the current backend does not implement team membership authorization or team-visible Artifact creation. The skill detects that capability gap and stops rather than presenting private knowledge as shared. No separate team MCP connection is needed until the backend exposes team-aware contracts.

## Verify and start Codex

```bash
codex mcp list
codex mcp get snippify-public
codex mcp get snippify-private
codex
```

## Current implementation gaps

- Login credentials are not connected to Codex MCP authentication. Private MCP still requires the separately issued Agent Token described above.
- Agent Token creation is currently a development provisioning flow; no production user-facing Agent Token issuance command is implemented.
- Team membership, team-scoped authorization, and team-visible Artifact transitions are not implemented.
