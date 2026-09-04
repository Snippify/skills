# Snippify Base skill

`snippify-base` gives reusable files and Snippify draft Artifacts the same small metadata identity. It is intended for both developers reviewing the convention and agents preparing content for Snippify.

## What happens

When the skill is active, the agent checks the beginning of the selected text file for a `snippify-metadata:` comment.

- If the comment exists, the agent reuses it and does not create a duplicate.
- If it is missing and the file format safely supports comments, the agent adds one near the top using that format's native comment syntax.
- If comments are unsafe or unsupported, such as in JSON, the file is left unchanged and the same information is attached to the draft Artifact request.
- Before an explicitly requested upload, the agent maps the header into `save_artifact`: `type_key`, `title`, and `summary` are top-level fields; the remaining portable values go in `metadata`.

The skill does not upload automatically. Saving requires an explicit request and a configured authenticated Snippify MCP connection. Every agent-created Artifact is still a private draft that requires human review.

## Metadata format

The logical envelope is a single JSON object:

```text
snippify-metadata: {"schema":"snippify/file-metadata/v1","type_key":"code","title":"Retry policy","summary":"Defines bounded retry behavior for outbound requests.","source_path":"internal/client/retry.go","language":"go","tags":["http","reliability"]}
```

A Go file would contain:

```go
// snippify-metadata: {"schema":"snippify/file-metadata/v1","type_key":"code","title":"Retry policy","summary":"Defines bounded retry behavior for outbound requests.","source_path":"internal/client/retry.go","language":"go","tags":["http","reliability"]}
package client
```

A Markdown file would contain:

```markdown
<!-- snippify-metadata: {"schema":"snippify/file-metadata/v1","type_key":"documentation","title":"Local setup","summary":"Explains how to run the project locally.","source_path":"docs/local-setup.md","language":"markdown","tags":["development"]} -->
```

Required keys are `schema`, `type_key`, `title`, and `summary`. `source_path`, `language`, and `tags` are included only when useful and known.

## Placement and safety

The metadata stays behind syntax that must legally come first: shebangs, encoding declarations, Go build constraints, XML declarations, doctypes, front matter, and required license headers. The agent does not add headers to binary, generated, vendored, lock, checksum, migration-history, or externally maintained files.

The metadata deliberately excludes ownership, Workspace IDs, agent/user identity, approval, visibility, trust, version IDs, timestamps, and secrets. Those values are either private, unstable, or controlled by the authenticated Snippify server.

## Using the skill

Example requests:

```text
Use $snippify-base to add missing metadata to internal/client/retry.go.
```

```text
Use $snippify-base and $snippify-private to prepare this document and upload it as a private draft Artifact.
```

For uploads, configure the `snippify-private` skill, MCP connection, and Agent Token separately. `snippify-base` owns the portable metadata convention; `snippify-private` owns connection, Workspace selection, idempotency, and the actual `save_artifact` call.
