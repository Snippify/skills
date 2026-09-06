#!/usr/bin/env python3
"""Maintain the compact project-local Snippify journal."""

from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import sys

HEADER = "v1"


def clean(value: str, name: str) -> str:
    value = value.strip()
    if not value or "\t" in value or "\n" in value or "\r" in value:
        raise ValueError(f"invalid {name}")
    return value


def project_root(raw: str) -> Path:
    root = Path(raw).resolve()
    if not root.is_dir():
        raise ValueError("project must be an existing directory")
    return root


def journal_path(root: Path) -> Path:
    return root / ".snippify" / "journal.tsv"


def load(root: Path) -> list[list[str]]:
    path = journal_path(root)
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != HEADER:
        raise ValueError(f"unsupported journal format: {path}")
    records: list[list[str]] = []
    for line in lines[1:]:
        if not line:
            continue
        fields = line.split("\t")
        if (fields[0] == "G" and len(fields) == 4) or (
            fields[0] == "S" and len(fields) == 5
        ):
            records.append(fields)
        else:
            raise ValueError(f"invalid journal record: {line}")
    return records


def save(root: Path, records: list[list[str]]) -> None:
    path = journal_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    body = "\n".join([HEADER, *("\t".join(record) for record in records)]) + "\n"
    temporary.write_text(body, encoding="utf-8")
    os.replace(temporary, path)


def relative_path(root: Path, raw: str, *, allow_dash: bool = False) -> str:
    if allow_dash and raw == "-":
        return "-"
    path = Path(raw)
    resolved = (root / path).resolve() if not path.is_absolute() else path.resolve()
    try:
        relative = resolved.relative_to(root)
    except ValueError as error:
        raise ValueError("path must be inside the project") from error
    return relative.as_posix()


def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()[:16]


def upsert(root: Path, record: list[str]) -> None:
    records = [
        existing
        for existing in load(root)
        if not (existing[0] == record[0] and existing[1] == record[1])
    ]
    records.append(record)
    save(root, records)


def matching_record(
    records: list[list[str]], kind: str, artifact: str
) -> list[str] | None:
    return next(
        (record for record in records if record[0] == kind and record[1] == artifact),
        None,
    )


def run(args: argparse.Namespace) -> int:
    root = project_root(args.project)
    records = load(root)

    if args.command == "lookup":
        artifact = clean(args.artifact, "artifact") if args.artifact else None
        path = relative_path(root, args.path) if args.path else None
        for record in records:
            if (artifact and record[1] == artifact) or (path and record[3] == path):
                print("\t".join(record))
        return 0

    artifact = clean(args.artifact, "artifact")
    if args.command == "check-get":
        version = clean(args.version, "version")
        record = matching_record(records, "G", artifact)
        if record and record[2] == version and record[3] != "-" and (root / record[3]).is_file():
            return 0
        return 1

    if args.command == "check-suggest":
        path = relative_path(root, args.path)
        full_path = root / path
        record = matching_record(records, "S", artifact)
        if record and record[3] == path and full_path.is_file() and record[4] == file_hash(full_path):
            return 0
        return 1

    version = clean(args.version, "version")
    if args.command == "record-get":
        path = relative_path(root, args.path, allow_dash=True)
        upsert(root, ["G", artifact, version, path])
        return 0

    if args.command == "record-suggest":
        path = relative_path(root, args.path)
        full_path = root / path
        if not full_path.is_file():
            raise ValueError("suggested path must be an existing file")
        upsert(root, ["S", artifact, version, path, file_hash(full_path)])
        return 0

    raise ValueError("unsupported command")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    subcommands = result.add_subparsers(dest="command", required=True)

    lookup = subcommands.add_parser("lookup")
    lookup.add_argument("--project", required=True)
    selector = lookup.add_mutually_exclusive_group(required=True)
    selector.add_argument("--artifact")
    selector.add_argument("--path")

    for name in ("check-get", "check-suggest", "record-get", "record-suggest"):
        command = subcommands.add_parser(name)
        command.add_argument("--project", required=True)
        command.add_argument("--artifact", required=True)
        if name in ("check-get", "record-get", "record-suggest"):
            command.add_argument("--version", required=True)
        if name in ("check-suggest", "record-get", "record-suggest"):
            command.add_argument("--path", required=True)
    return result


if __name__ == "__main__":
    try:
        raise SystemExit(run(parser().parse_args()))
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(2) from error
