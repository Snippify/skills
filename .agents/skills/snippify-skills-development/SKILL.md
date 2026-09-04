---
name: snippify-skills-development
description: Maintain this Snippify skills repository, including bundled skill files, npm/npx packaging, install.sh, and Codex MCP setup docs.
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
- `skills/SETUP.md` is the detailed local Snippify setup guide.

## Installer Constraints

The npm installer should not configure local agent state. Keep it focused on installing bundled skills.

The shell installer may configure local Codex state:

- Install relevant Snippify skills.
- Add the public Codex MCP connection.
- Run `snippify login` when private setup is requested and the CLI is available.
- Prompt for Snippify username and password during private setup.
- Pass login credentials to `snippify login` without printing the password.
- Write a restricted credentials env file for private MCP runtime values.
- Configure private Codex MCP with `--bearer-token-env-var SNIPPIFY_TOKEN`.

Do not write plaintext passwords into repository files, committed config, examples, generated credential files, or shell history. Private MCP should read `SNIPPIFY_TOKEN` from the user's environment. If a credentials file is written, keep it outside the repository by default and set restrictive permissions.

## Auth Constraint

Currently, `snippify login` stores API credentials but does not issue the Agent Token required by private MCP. The private MCP token must have `artifact:read` and `artifact:create` scopes.

Until Snippify exposes production token issuance, installers should accept `SNIPPIFY_TOKEN` from the environment or prompt for it without echoing. Username/password login is still useful for the user's Snippify API session, but Codex private MCP must receive `SNIPPIFY_TOKEN` at runtime.

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
