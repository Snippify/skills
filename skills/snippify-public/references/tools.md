# Anonymous public MCP tools

These tools are read-only and require no token. The connected server remains authoritative if its discovered schema differs.

## `list_artifacts`

Input:

```json
{
  "tag": "optional exact tag",
  "purpose": "optional exact purpose"
}
```

- Both filters are optional and case-insensitive.
- When both are present, both must match.

The response contains compact Artifact entries with:

- `id`
- `tag`
- `purpose`
- `visibility`
- `state`
- current approved version `id`, `version_number`, `suggested_user_id`, `suggested_by`, `review_status`, `title`, `summary`, and `files`

Text is intentionally omitted from lists.

## `search_artifacts`

Input:

```json
{
  "query": "retry policy"
}
```

The result has the same compact shape as `list_artifacts`. Search covers Artifact tag and purpose plus the approved current version's title and summary.

## `get_artifact`

Input:

```json
{
  "artifact_id": "11111111-1111-4111-8111-111111111111"
}
```

The response includes Artifact ID, tag, purpose, `public` visibility, active state, and the approved current version. The version includes identity, suggestion identity/type, review status, title, summary, nullable text, and file metadata.

Non-public, inactive, draft-only, and missing Artifacts are indistinguishable through this tool.
