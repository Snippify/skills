# Authenticated Snippify MCP tools

The connection must send a valid Snippify access token as a bearer token. The server derives `owner_id`, `suggested_user_id`, and `suggested_by` from that token.

## `create_artifact`

Input:

```json
{
  "tag":"code",
  "purpose":"Reuse a bounded outbound retry policy.",
  "title":"Retry policy",
  "summary":"Retries transient HTTP failures with bounded backoff.",
  "files":[{
    "name":"retry.go",
    "summary":"Retry implementation",
    "content_base64":"cGFja2FnZSByZXRyeQo="
  }]
}
```

`tag`, `purpose`, and `title` are required. `summary`, nullable `text`, and `files` are optional. Each file input contains `name`, `summary`, and base64 content. Do not send `path` or `size`; the server derives them after persistence and returns them as output metadata. The returned draft version has `candidate: false`.

Use `text` instead of `files` for standalone content or a script excerpt. For a whole file, use `files` and omit `text`; with multiple files, always leave `text` empty.

## `suggest_artifact_version`

Input:

```json
{
  "artifact_id":"11111111-1111-4111-8111-111111111111",
  "title":"Retry policy v2",
  "summary":"Adds server-directed retry delays.",
  "files":[{
    "name":"retry.go",
    "summary":"Complete updated retry implementation",
    "content_base64":"cGFja2FnZSByZXRyeQo="
  }]
}
```

`artifact_id` and `title` are required. The target must be active and public. File inputs never accept caller-provided `path` or `size`; those fields appear only in the returned stored-file metadata.

The result includes `created` and the draft version with `candidate: false`. `created: false` means the authenticated user's existing draft was replaced in place, retaining its version identity and number.
