# Private Snippify connection

Installing the skill and connecting the authenticated MCP server are separate operations.

Install from this checkout:

```bash
npx skills add . --skill snippify-private
```

Configure the agent host with the Snippify Streamable HTTP URL ending in `/mcp` and an Agent Token stored through the host's environment or secret facility. The token needs `artifact:read` for retrieval and `artifact:create` for saving.

Never place a plaintext token in this skill, committed configuration, source code, command history examples, or Artifact content. Follow the agent host's current MCP configuration syntax instead of guessing keys.

Verify discovery of `list_workspaces`, `save_artifact`, `get_artifact`, and `list_artifact_versions`. Local stdio has no implicit tenant identity or Artifact scopes, so private operations require authenticated Streamable HTTP.
