#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
on-exit+catchup-sync.py

Detects chain tasks completed via sync (from another host without hooks)
and feeds them to on-modify-nautical.py to spawn the next child.

Only runs on `task sync`. Queries for completed tasks where:
  - chainID is non-empty (part of a nautical chain)
  - nextLink is empty (child never spawned — orphaned by sync)
  - modified within the last 2 months (covers rare syncs)

For each match: constructs synthetic old+new JSON and pipes to
on-modify-nautical.py. After all spawns are queued, explicitly drains
via on-exit-nautical.py.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import traceback
from pathlib import Path

HOOK_DIR = Path(__file__).parent
ON_MODIFY_HOOK = HOOK_DIR / "on-modify-nautical.py"
ON_EXIT_NAUTICAL = HOOK_DIR / "on-exit-nautical.py"

LOOKBACK = "2months"


# ── helpers ──────────────────────────────────────────────────────────────────

def _parse_args(argv: list[str]) -> dict[str, str]:
    """Parse Hooks v2 command-line arguments: key:value pairs."""
    parsed: dict[str, str] = {}
    for arg in argv:
        if ":" in arg:
            key, _, value = arg.partition(":")
            parsed[key] = value
    return parsed


def _note(msg: str) -> None:
    """Write feedback to stderr (visible in TW output as footnote)."""
    try:
        sys.stderr.write(f"[catchup-sync] {msg}\n")
        sys.stderr.flush()
    except Exception:
        pass


# ── task export ──────────────────────────────────────────────────────────────

def _export_orphaned_chain_tasks() -> list[dict]:
    """Export completed chained tasks with nextLink still empty."""
    cmd = [
        "task",
        "rc.hooks=off",
        "rc.verbose=nothing",
        "rc.context=none",
        "status:completed",
        "chainID.any:",
        "nextLink.none:",
        f"modified.after:now-{LOOKBACK}",
        "export",
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return []

    if result.returncode != 0:
        # rc=1 with empty stdout = no matches (normal)
        if result.returncode == 1 and not result.stdout.strip():
            return []
        return []

    stdout = result.stdout.strip()
    if not stdout:
        return []

    try:
        tasks = json.loads(stdout)
        return [t for t in tasks if isinstance(t, dict)] if isinstance(tasks, list) else []
    except json.JSONDecodeError:
        return []


# ── on-modify feed ───────────────────────────────────────────────────────────

def _feed_to_on_modify(task: dict) -> bool:
    """
    Feed a completed chain task to on-modify-nautical.py.
    Constructs synthetic old (status=pending) + real new (completed).
    """
    old = dict(task)
    old["status"] = "pending"
    for f in ("end", "resolved", "start"):
        old.pop(f, None)

    stdin_data = json.dumps(old, ensure_ascii=False) + "\n" + json.dumps(task, ensure_ascii=False) + "\n"

    try:
        result = subprocess.run(
            [sys.executable, str(ON_MODIFY_HOOK)],
            input=stdin_data,
            capture_output=True,
            text=True,
            timeout=30,
            env=os.environ,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False

    return result.returncode == 0


# ── queue drain ──────────────────────────────────────────────────────────────

def _drain_spawn_queue() -> bool:
    """Call on-exit-nautical.py to drain the queue immediately."""
    if not ON_EXIT_NAUTICAL.is_file():
        return False

    try:
        result = subprocess.run(
            [sys.executable, str(ON_EXIT_NAUTICAL)],
            capture_output=True,
            text=True,
            timeout=30,
            env=os.environ,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False

    return result.returncode == 0


# ── main ─────────────────────────────────────────────────────────────────────

def main() -> int:
    args = _parse_args(sys.argv[1:])
    command = args.get("command", "")

    # Only act on sync — TW 3.x reports "synchronize", 2.x reports "sync"
    if command not in ("sync", "synchronize"):
        return 0

    if not ON_MODIFY_HOOK.is_file():
        return 0

    tasks = _export_orphaned_chain_tasks()
    if not tasks:
        return 0

    ok = 0
    for task in tasks:
        if not task.get("chainID") or task.get("nextLink"):
            continue
        if task.get("status") != "completed":
            continue
        if _feed_to_on_modify(task):
            ok += 1

    if ok > 0:
        _drain_spawn_queue()
        _note(f"processed {ok}/{len(tasks)} orphaned chain task(s)")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SystemExit:
        raise
    except Exception:
        try:
            sys.stderr.write(f"[catchup-sync] error: {traceback.format_exc()}\n")
        except Exception:
            pass
        raise SystemExit(0)
