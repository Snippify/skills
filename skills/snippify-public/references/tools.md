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
- `current_version`: the selected approved version, containing identity and review metadata, `title`, `summary`, and a `content` manifest
- `content.has_text`, `content.text_size`, and a rough `content.estimated_tokens` when text exists
- `content.files`: file metadata containing `name`, `size`, `summary`, and a rough `estimated_tokens`

Full text, file contents, storage paths, and version history are intentionally omitted.

## `search_artifacts`

Input:

```json
{
  "query": "retry policy"
}
```

The result has the same `artifacts` and optional `my` collections as `list_artifacts`. Search applies the same query to both collections and covers Artifact tag and purpose plus the approved current version's title and summary. Use concise discovery terms such as `python jwt`; the server treats `query` as one case-insensitive substring rather than interpreting a full instruction.

## `get_artifact`

Input:

```json
{
  "artifact_id": "11111111-1111-4111-8111-111111111111"
}
```

The response is a lightweight content manifest with the same Artifact and `current_version` metadata as discovery results. It never contains full text or file contents. Use purpose, title, summary, and file summaries to decide what—if anything—to retrieve.

Anonymous callers can retrieve only public Artifacts. Authenticated callers can also retrieve their own private Artifacts. Another user's private Artifact, a team Artifact, an inactive Artifact, an Artifact without an approved candidate, and a missing Artifact are indistinguishable through this tool.

## `get_artifact_text`

Input:

```json
{"artifact_id":"11111111-1111-4111-8111-111111111111"}
```

Returns only `artifact_id`, the approved current `version_id`, and its full nullable `text`. Call it only when the manifest has `has_text: true` and the actual text is required. It never returns files.

## `get_artifact_file`

Input:

```json
{
  "artifact_id":"11111111-1111-4111-8111-111111111111",
  "file_name":"middleware.go"
}
```

Use the exact name from `current_version.content.files`. The response contains metadata and content for only that file. `encoding` is `utf-8` for textual content or `base64` for binary content; interpret `content` accordingly. If names are duplicated, retrieval is rejected as ambiguous rather than returning multiple files.
