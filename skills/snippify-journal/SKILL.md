---
name: snippify-journal
description: Maintain a tiny project-local journal for materialized Snippify Artifact content and file suggestions. Use with Snippify read or contribution actions to avoid repeated content retrieval and context.
---

# Snippify Journal

Keep `.snippify/journal.tsv` in the current project as a compact cache. Create it automatically after successfully materializing content from `get_artifact_text` or `get_artifact_file`, or after a file-based `suggest_artifact_version`; do not journal metadata-only `get_artifact` calls.

Use the bundled [`scripts/journal.py`](scripts/journal.py) helper. Resolve its path from this skill directory and pass the project root explicitly.

## Before a Snippify action

- Never load the whole journal. Query one matching record with `lookup --artifact ID` or `lookup --path PATH`.
- After search/list or `get_artifact` reveals a current version, run `check-get --artifact ID --version VERSION` before fetching its content. Exit code 0 means that version was already materialized at an existing project path, so reuse that file unless the user requests a refresh. Exit code 1 means retrieve only the needed text or selected file.
- Before suggesting a file, run `check-suggest --artifact ID --path PATH`. Exit code 0 means the same file bytes already produced the recorded draft; do not repeat the suggestion unless replacing it is explicitly intended.
- Use short discovery queries and the exact stored IDs. The journal never substitutes for server authorization or current server state.

## Token discipline

- Read and emit only the matching journal line; never narrate the journal workflow.
- Search with two to five discriminating words. Use discovery metadata and the manifest to choose one Artifact and one content source before fetching anything large.
- Do not echo MCP arguments, base64 file content, full tool responses, or retrieved Artifact text into chat. Apply retrieved content directly and report only the Artifact ID, version ID, and outcome.
- Do not call list/search/get again when a valid journal check already answers the question.

## After a successful action

Record silently; the helper prints nothing on success:

```text
python3 <skill-dir>/scripts/journal.py record-get --project <root> --artifact <artifact-id> --version <current-version-id> --path <project-path-or-dash>
python3 <skill-dir>/scripts/journal.py record-suggest --project <root> --artifact <artifact-id> --version <draft-version-id> --path <project-file>
```

For a retrieval applied to a file, record its project-relative path. Use `--path -` only when the Artifact was consumed without a durable local file; that record documents the version but does not permit skipping a later get.

## Compact format and boundaries

The helper maintains one tab-separated record per action and Artifact:

```text
v1
G	<artifact-id>	<candidate-version-id>	<path-or-dash>
S	<artifact-id>	<draft-version-id>	<path>	<sha256-first-16>
```

It replaces stale `G` or `S` records instead of appending history. Never put bearer tokens, credentials, Artifact contents, prompts, command output, or verbose prose in the journal. Never upload or suggest the journal itself. Treat it as local cache metadata, not authoritative knowledge.
