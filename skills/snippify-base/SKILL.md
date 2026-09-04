---
name: snippify-base
description: Add a portable Snippify metadata header to reusable text files, or map the same metadata into a Snippify Artifact draft when an in-file comment is missing or unsafe. Use when preparing files or content for Snippify capture and upload.
---

# Snippify Base

Give reusable content a small, consistent identity without changing its behavior.

## Metadata envelope

Use a single-line JSON object prefixed by `snippify-metadata:`. Include:

- `schema`: always `snippify/file-metadata/v1`.
- `type_key`: a concise Artifact type such as `code`, `rule`, `prompt`, `skill`, `decision`, `workflow`, `documentation`, or `custom`.
- `title`: a human-readable name, at most 240 bytes.
- `summary`: one concise sentence describing the reusable purpose.
- `source_path`: repository-relative path when known. Omit for content without a stable path.
- `language`: lowercase language or format name when known.
- `tags`: optional short, non-sensitive discovery terms. Omit rather than emit an empty list.

Do not add owner, user, agent, Workspace, approval, visibility, review, trust, Artifact ID, version, timestamps, credentials, or secrets. Snippify derives identity and review state from the authenticated operation.

Example payload, shown without a comment wrapper:

```text
snippify-metadata: {"schema":"snippify/file-metadata/v1","type_key":"code","title":"Retry policy","summary":"Defines bounded retry behavior for outbound requests.","source_path":"internal/client/retry.go","language":"go","tags":["http","reliability"]}
```

## Add metadata to a file

1. Inspect the file and its mandatory preamble. Search the opening portion for `snippify-metadata:` before editing.
2. If a header already exists, do not add another or rewrite it unless the user asks to refresh it.
3. If comments are supported, wrap the envelope in the native comment syntax and place it near the top without displacing required syntax:
   - Keep Unix shebangs and Python encoding declarations first.
   - Keep Go build constraints together at the beginning; add the metadata after the constraint block and its required blank line.
   - Keep XML declarations, doctypes, and Markdown/YAML front matter first.
   - Keep license headers in their required position; place metadata immediately after them.
4. Preserve formatting and executable behavior. Add only the metadata comment and any separator newline required by the language.

Use `//` for Go, JavaScript, TypeScript, Java, C, C++, Rust, and similar languages; `#` for Python, Ruby, shell, YAML, and TOML; `--` for SQL and Lua; `<!-- ... -->` for Markdown, HTML, and XML; and `/* ... */` for CSS. Follow an existing valid comment convention when it differs.

Do not insert comments into JSON or another comment-free format. Do not edit binary, generated, vendored, lock, checksum, migration-history, or externally maintained files merely to add metadata. In those cases, carry the envelope in the draft Artifact request instead.

## Prepare a draft Artifact

Before an authorized `save_artifact` call, read an existing header when present; otherwise infer the envelope from the selected content and path. Map it as follows:

- `type_key`, `title`, and `summary` become the corresponding top-level `save_artifact` fields.
- Put `schema`, and any available `source_path`, `language`, and `tags`, in the request's `metadata` object.
- Put the reusable material in `content`; do not put credentials, personal data, raw transcripts, or unrelated repository content there.

Always send a non-empty metadata object for a draft prepared by this skill. If no optional fields apply, use:

```json
{"schema":"snippify/file-metadata/v1"}
```

Saving changes external state. Prepare metadata proactively, but call `save_artifact` only when the user has explicitly asked to capture, sync, save, or upload the content. Follow the connected server's current schema and `$snippify-private` for Workspace resolution, idempotency, authentication, and result reporting. Agent-created Artifacts remain private drafts pending human review.

## Report

State whether metadata was added to the file, reused from an existing header, or supplied only in the draft request. Mention skipped files and the compatibility reason; never claim a draft was uploaded unless the tool call succeeded.
