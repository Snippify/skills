---
name: snippify-base
description: Add a portable Snippify metadata header to reusable files or map file content into the current Snippify Artifact creation and suggestion contracts.
---

# Snippify Base

Give reusable content a small, consistent identity without changing its behavior.

## Metadata envelope

Use a single-line JSON object prefixed by `snippify-metadata:`. Include:

- `schema`: always `snippify/file-metadata/v1`.
- `tag`: a concise discovery category such as `code`, `rule`, `prompt`, `skill`, `decision`, `workflow`, or `documentation`.
- `purpose`: one concise statement of how the reusable material should be used.
- `title`: a human-readable name, at most 240 bytes.
- `summary`: one concise sentence describing the reusable purpose.
- `source_path`: repository-relative path when known. Omit for content without a stable path.
- `language`: lowercase language or format name when known.
- `tags`: optional short, non-sensitive discovery terms. Omit rather than emit an empty list.

Do not add owner, user, agent, Workspace, approval, visibility, review, trust, Artifact ID, version, timestamps, credentials, or secrets. Snippify derives identity and review state from the authenticated operation.

Example payload, shown without a comment wrapper:

```text
snippify-metadata: {"schema":"snippify/file-metadata/v1","tag":"code","purpose":"Reuse the outbound HTTP retry policy.","title":"Retry policy","summary":"Defines bounded retry behavior for outbound requests.","source_path":"internal/client/retry.go","language":"go","tags":["http","reliability"]}
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

Before an authorized `create_artifact` or `suggest_artifact_version` call, read an existing header when present; otherwise infer the envelope from the selected content and path. Map it as follows:

- `tag`, `purpose`, `title`, and `summary` become the corresponding tool fields.
- Put the reusable material in `text`.
- Map relevant files to upload entries with `name`, base64 content, and a concise `summary`. Do not provide `path` or `size`; the server derives them.

Creating or suggesting changes external state. Prepare metadata proactively, but call mutation tools only when the user explicitly asks to capture, sync, save, upload, or suggest the content. Follow the connected server's current schema and `$snippify-contribute` for authentication, draft replacement semantics, and result reporting.

## Report

State whether metadata was added to the file, reused from an existing header, or supplied only in the draft request. Mention skipped files and the compatibility reason; never claim a draft was uploaded unless the tool call succeeded.
