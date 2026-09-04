---
name: snippify-skills-development
description: Maintain this Snippify skills repository, including public discovery, authenticated contribution, npm/npx packaging, install.sh, and Codex MCP setup docs.
---

# Snippify Skills Development

Use this skill when changing this repository's Snippify skill packages, installers, or agent setup documentation.

## Scope

This repository packages Snippify skills for Codex and installs them through npm or the local shell installer.

Supported agent hosts:

- `codex`

Keep agent support explicit. Do not add another agent name to scripts or docs until the installer has been tested with that host's skill and MCP configuration commands.

## Layout

- `skills/*/SKILL.md` contains agent-facing skill instructions.
- `skills/*/agents/openai.yaml` contains OpenAI/Codex presentation metadata and MCP dependency hints.
- `skills/*/references/` contains supporting docs loaded only when needed by a skill.
- `bin/install.js` is the npm/npx entry point and should only install bundled skills with `npx skills add`.
- `install.sh` is the client setup script for installing skills and Codex MCP connections.
- `README.md` documents installation and MCP connection setup.

## Installer Constraints

The npm installer should not configure local agent state. Keep it focused on installing bundled skills.

The shell installer may configure local Codex state:

- Install relevant Snippify skills.
- Add the anonymous public Codex MCP connection.
- Run `snippify login` when authenticated setup is requested and the CLI is available.
- Prompt for Snippify username and password during authenticated setup.
- Pass login credentials to `snippify login` without printing the password.
- Write a restricted credentials env file for authenticated MCP runtime values.
- Configure authenticated Codex MCP with `--bearer-token-env-var SNIPPIFY_TOKEN`.

Do not write plaintext passwords into repository files, committed config, examples, generated credential files, or shell history. Authenticated MCP should read `SNIPPIFY_TOKEN` from the user's environment. If a credentials file is written, keep it outside the repository by default and set restrictive permissions.

## Auth Constraint

Authenticated MCP uses a Snippify access JWT. Agent-login tokens identify suggestions as `agent`; user-login tokens identify them as `client`. Installers should accept the access token through `SNIPPIFY_TOKEN` or prompt without echoing. Never use a refresh token as the MCP bearer token.

## Verification

Before finishing installer or packaging changes, run the relevant checks:

```bash
node bin/install.js --list
node bin/install.js --dry-run
sh -n install.sh
npm pack --dry-run
```

If npm cannot write to its default cache in the sandbox, use a task-specific cache:

```bash
npm_config_cache=/tmp/snippify-skills-npm-cache npm pack --dry-run
```
