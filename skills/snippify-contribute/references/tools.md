# Authenticated Snippify MCP tools

The connection must send a valid Snippify access token as a bearer token. The server derives `owner_id`, `suggested_user_id`, and `suggested_by` from that token.

## `list_own_artifacts`

Accepts optional `tag` and `purpose` exact, case-insensitive filters. The response contains active owned Artifacts using the compact public list shape. Draft-only Artifacts have a null `current_version`.

## `search_own_artifacts`

Input:

```json
{"query":"retry policy"}
```

Search covers owned Artifact tag and purpose plus all non-deleted version titles and summaries.

## `create_artifact`

Input:

```json
{
  "tag":"code",
  "purpose":"Reuse a bounded outbound retry policy.",
  "title":"Retry policy",
  "summary":"Retries transient HTTP failures with bounded backoff.",
  "text":"optional reusable content",
  "files":[{"name":"retry.go","size":1200,"path":"internal/client/retry.go","summary":"Retry implementation"}]
}
```

`tag`, `purpose`, and `title` are required. `summary`, nullable `text`, and `files` are optional. The result contains the new active public Artifact and its first draft version.

## `suggest_artifact_version`

Input:

```json
{
  "artifact_id":"11111111-1111-4111-8111-111111111111",
  "title":"Retry policy v2",
  "summary":"Adds server-directed retry delays.",
  "text":"complete suggested replacement",
  "files":[]
}
```

`artifact_id` and `title` are required. The target must be active and public. The result includes `created` and the draft version. `created: false` means the authenticated user's existing draft was replaced in place, retaining its version identity and number.
