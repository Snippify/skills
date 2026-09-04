# Snippify Skills

Install the Snippify Codex skills from npm with one `npx` command.

```bash
npx snippify-skills
```

That command installs all bundled skills into the current Codex environment:

- `snippify-base`
- `snippify-private`
- `snippify-public`
- `snippify-team`

## Install One Skill

```bash
npx snippify-skills --skill snippify-public
```

Repeat `--skill` to install a subset:

```bash
npx snippify-skills \
  --skill snippify-base \
  --skill snippify-private
```

## Install From GitHub Before Publishing

Until the package is published to npm, users can install directly from the GitHub repository:

```bash
npx github:<owner>/<repo>
```

Replace `<owner>/<repo>` with the actual GitHub repository path.

## What The Installer Runs

The package contains the skills under `skills/` and exposes the `snippify-skills` binary. The binary delegates to the standard skills installer:

```bash
npx --yes skills add <package-root> \
  --skill snippify-base \
  --skill snippify-private \
  --skill snippify-public \
  --skill snippify-team \
  --agent codex
```

Preview the command without installing:

```bash
npx snippify-skills --dry-run
```

List bundled skills:

```bash
npx snippify-skills --list
```

## Local Development

From this repository:

```bash
npm run install:skills
npm run pack:check
```

You can still call the underlying installer directly:

```bash
npx skills add . \
  --skill snippify-base \
  --skill snippify-private \
  --skill snippify-public \
  --skill snippify-team \
  --agent codex
```

## Snippify MCP Setup

The skills describe how agents should use Snippify, but MCP connections are configured separately.

Public tools are anonymous:

```bash
codex mcp add snippify-public \
  --url http://127.0.0.1:8081/mcp
```

Private tools require an Agent Token exposed as an environment variable:

```bash
printf 'Snippify Agent Token: '
IFS= read -r -s SNIPPIFY_TOKEN
printf '\n'
export SNIPPIFY_TOKEN

codex mcp add snippify-private \
  --url http://127.0.0.1:8081/mcp \
  --bearer-token-env-var SNIPPIFY_TOKEN
```

See [skills/SETUP.md](skills/SETUP.md) for the full local Snippify setup flow.

## Publish

When the repository is ready:

```bash
npm publish
```

After publishing, users can install the skills with:

```bash
npx snippify-skills
```
