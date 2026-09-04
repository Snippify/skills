# Anonymous public MCP tools

Both tools are read-only, idempotent, and require no token. The connected server remains authoritative if its discovered schema differs.

## `list_public_artifacts`

Input:

```json
{
  "limit": 20,
  "cursor": "optional-opaque-cursor"
}
```

- `limit` is optional, defaults to 20, and must be between 1 and 50.
- `cursor` is optional. Reuse only the opaque `next_cursor` returned by the preceding page.

The response contains compact Artifact entries with:

- `id`
- `type_key`
- `state`
- `updated_at`
- current approved version `id`, `version_number`, `title`, `summary`, `created_at`, and `is_current`
- optional `next_cursor`

Content and metadata are intentionally omitted from lists.

## `get_public_artifact`

Current approved version:

```json
{
  "artifact_id": "11111111-1111-4111-8111-111111111111"
}
```

Exact approved version:

```json
{
  "artifact_id": "11111111-1111-4111-8111-111111111111",
  "version_number": 2
}
```

The response includes Artifact identity, type, `public` visibility, lifecycle state, current version ID, timestamps, version identity/title/summary, content, and metadata.

Private and team Artifacts are indistinguishable from missing Artifacts. Draft and rejected versions are never returned, even when their UUID or version number is known.
