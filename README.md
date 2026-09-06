# Snippify Skills

Install the Snippify Codex skills from npm:

```bash
npx snippify-skills
```

The package includes:

- `snippify-base` for portable file metadata and Artifact request preparation.
- `snippify-public` for read-only public Artifact search, listing, and retrieval plus access to the authenticated user's own private Artifacts.
- `snippify-contribute` for authenticated creation, owned-Artifact discovery, and version suggestions.

## Client setup

Use the shell installer to install skills and configure Codex MCP connections:

```bash
curl -fsSL https://raw.githubusercontent.com/Snippify/skills/main/install.sh -o /tmp/snippify-install.sh && sh /tmp/snippify-install.sh
```

Or with `wget`:

```bash
wget -q https://raw.githubusercontent.com/Snippify/skills/main/install.sh -O /tmp/snippify-install.sh  && sh /tmp/snippify-install.sh
```

The installer securely prompts for a Snippify access token. Leave it blank to install public skills and the public MCP connection only.

Without a token, the installer configures public skills and the public MCP connection only. `SNIPPIFY_TOKEN` must be a current Snippify access token. Agent-login tokens mark suggestions as `agent`; user-login tokens mark them as `client`. Refresh tokens are not valid MCP bearer tokens.

The default MCP endpoint is `http://127.0.0.1:8081/mcp`. Override it with `--public-url`, `--authenticated-url`, `SNIPPIFY_PUBLIC_MCP_URL`, or `SNIPPIFY_AUTHENTICATED_MCP_URL`.

The installer writes authenticated environment values to `~/.config/snippify/credentials.env` by default with restricted permissions. Load it before starting Codex:

```bash
. ~/.config/snippify/credentials.env
codex
```

## Install selected skills

```bash
npx snippify-skills --skill snippify-public
npx snippify-skills --skill snippify-base --skill snippify-contribute
```

Install directly from this checkout:

```bash
npx skills add . \
  --skill snippify-base \
  --skill snippify-public \
  --skill snippify-contribute \
  --agent codex
```

## Manual MCP configuration

Anonymous public connection:

```bash
codex mcp add snippify-public --url http://127.0.0.1:8081/mcp
```

Authenticated connection:

```bash
codex mcp add snippify-authenticated \
  --url http://127.0.0.1:8081/mcp \
  --bearer-token-env-var SNIPPIFY_TOKEN
```

Never commit or print bearer tokens.

## Development checks

```bash
node bin/install.js --list
node bin/install.js --dry-run
sh -n install.sh
npm pack --dry-run
```
