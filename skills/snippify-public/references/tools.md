# Read-only Artifact MCP tools

These tools are read-only and support anonymous access. When the user already has an authenticated MCP connection, use that connection and let the MCP client attach its configured bearer header. Otherwise use the public connection without an Authorization header. The connected server remains authoritative if its discovered schema differs.

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

The response contains:

- `artifacts`: compact active public Artifact entries with approved current versions.
- `my`: the authenticated user's matching active private Artifact entries with approved current versions. This key is omitted for anonymous callers and is present as an empty list when an authenticated caller has no matches.

Each compact Artifact entry contains:

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

The result has the same `artifacts` and optional `my` collections as `list_artifacts`. Search applies the same query to both collections and covers Artifact tag and purpose plus the approved current version's title and summary.

## `get_artifact`

Input:

```json
{
  "artifact_id": "11111111-1111-4111-8111-111111111111"
}
```

The response includes Artifact ID, tag, purpose, visibility, active state, and the approved current version. The version includes identity, suggestion identity/type, review status, title, summary, nullable text, and file metadata.

Anonymous callers can retrieve only public Artifacts. Authenticated callers can also retrieve their own private Artifacts. Another user's private Artifact, a team Artifact, an inactive or draft-only Artifact, and a missing Artifact are indistinguishable through this tool.
