# Private Snippify MCP tools

The connected server is authoritative. These are the current private Artifact contracts.

## `list_workspaces`

Requires `artifact:read`. It accepts an empty object and returns Workspaces owned by the authenticated user with `id`, `name`, `slug`, and `kind`.

## `save_artifact`

Requires `artifact:create`. It atomically creates a private Artifact and immutable version-1 draft.

- `workspace_id`: required owned Workspace UUID.
- `idempotency_key`: required stable key, 1–128 bytes.
- `type_key`: required extensible type, 1–80 bytes.
- `title`: required, 1–240 bytes.
- `summary`: optional, at most 16 KiB.
- `content`: required JSON object, at most 256 KiB.
- `metadata`: optional JSON object, at most 64 KiB.
- `change_summary`: optional, at most 4 KiB.

The result includes `created` and the Artifact version. `created: false` means an identical request was replayed; using the same key with different content is a conflict.

## `get_artifact`

Requires `artifact:read`. Provide `workspace_id`, `artifact_id`, and optionally a positive `version_number`. Without a version number, the server returns the current approved version or the newest draft when none is approved.

## `list_artifact_versions`

Requires `artifact:read`. Provide `workspace_id` and `artifact_id`. It returns compact version metadata without content; use `get_artifact` for an exact snapshot.

## Current limits

Private search, direct version editing, approval, publication, usage reporting, verification, and improvement suggestions are not exposed. Do not simulate them through unrelated tools or direct database access.
