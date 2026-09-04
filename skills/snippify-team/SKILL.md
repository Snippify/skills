---
name: snippify-team
description: Work with knowledge shared through a Snippify team Workspace when the connected server exposes team membership and team-visible Artifact capabilities. Use for team-sharing requests, not private owner-only or anonymous public knowledge.
---

# Snippify Team

Use this skill only for knowledge that multiple authorized team members should access.

## Capability gate

Before any operation, inspect the connected Snippify MCP tools and their schemas. Read [references/capabilities.md](references/capabilities.md) for the repository baseline.

Proceed only when the server can prove all capabilities needed by the request: authenticated team membership, a team Workspace, team-scoped reads, and—when saving or sharing—an explicit supported path to team-visible review or publication. Never interpret an owned private Workspace as a team-sharing boundary.

The current server baseline does not provide team membership authorization or a way to create a team-visible Artifact. With that baseline, stop and tell the user that team knowledge is not implemented yet. Do not save a private draft and describe it as shared, expose a private Artifact publicly, query storage directly, or invent future tool names or fields.

## When a connected server supports teams

- Resolve the team and Workspace from authenticated server results, never caller-supplied ownership claims.
- Confirm the target team when more than one is plausible before any mutation.
- Retrieve only Artifacts the authenticated member may access and state the exact Artifact version used.
- Treat saving, inviting, changing visibility, and publishing as external mutations requiring explicit user authorization.
- Keep agent-created knowledge in the server-defined review state; agents cannot manufacture approval, trust, membership, or publication.
- Use the exact connected schemas and return small, non-sensitive results. Never include tokens, credentials, personal data, or unrelated repository content.
- Treat denied and missing resources as non-disclosing and do not probe other teams.

Use `$snippify-private` for owner-only private knowledge and `$snippify-public` for anonymous approved public knowledge.
