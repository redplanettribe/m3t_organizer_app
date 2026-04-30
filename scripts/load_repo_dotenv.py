#!/usr/bin/env python3
"""
Load repo-root `.env` without overriding variables already set in environment.

Usage (bash):
  eval "$(python3 scripts/load_repo_dotenv.py "$REPO_ROOT")"
"""

from __future__ import annotations

import os
import re
import shlex
import sys
from pathlib import Path

_KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def parse_dotenv_file(path: Path) -> list[tuple[str, str]]:
    if not path.is_file():
        return []
    pairs: list[tuple[str, str]] = []
    text = path.read_text(encoding="utf-8")
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export ") and "=" in line[7:]:
            line = line[7:].strip()
        if "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip()
        if not _KEY_RE.match(key):
            continue
        if len(val) >= 2 and val[0] == val[-1] and val[0] in ("'", '"'):
            val = val[1:-1]
        pairs.append((key, val))
    return pairs


def merge_repo_dotenv(repo_root: str, *, override: bool = False) -> None:
    for key, val in parse_dotenv_file(Path(repo_root) / ".env"):
        if not override and key in os.environ:
            continue
        os.environ[key] = val


def shell_exports(repo_root: str) -> str:
    lines: list[str] = []
    for key, val in parse_dotenv_file(Path(repo_root) / ".env"):
        if key in os.environ:
            continue
        lines.append(f"export {key}={shlex.quote(val)}")
    return "\n".join(lines) + ("\n" if lines else "")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: load_repo_dotenv.py <repo_root>", file=sys.stderr)
        raise SystemExit(2)
    sys.stdout.write(shell_exports(sys.argv[1]))
