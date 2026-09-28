#!/usr/bin/env python3
"""Summarize observable metrics and issue signals in a CAD JSONL run log."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any


def load_records(path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as stream:
        for number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            record = json.loads(line)
            if not isinstance(record, dict):
                raise ValueError(f"line {number}: expected JSON object")
            records.append(record)
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", required=True)
    args = parser.parse_args()

    path = Path(args.log).expanduser().resolve()
    records = load_records(path)
    events = Counter(str(item.get("event", "unknown")) for item in records)
    statuses = Counter(str(item.get("status", "unknown")) for item in records)
    run_ids = sorted({str(item.get("run_id")) for item in records if item.get("run_id")})
    tool_calls = [item for item in records if item.get("event") == "tool"]
    durations = [
        item.get("payload", {}).get("duration_ms")
        for item in tool_calls
        if isinstance(item.get("payload"), dict)
        and isinstance(item.get("payload", {}).get("duration_ms"), (int, float))
    ]
    result_counts = [
        item.get("payload", {}).get("result_count")
        for item in tool_calls
        if isinstance(item.get("payload"), dict)
        and isinstance(item.get("payload", {}).get("result_count"), int)
    ]
    issue_signals = []
    if statuses["failed"] or statuses["timeout"] or statuses["partial"]:
        issue_signals.append("tool_or_run_failure")
    if events["issue"]:
        issue_signals.append("recorded_issue")

    summary = {
        "schema_version": "1.0",
        "source": str(path),
        "run_ids": run_ids,
        "records": len(records),
        "events": dict(events),
        "statuses": dict(statuses),
        "tool_calls": len(tool_calls),
        "tool_duration_ms_total": sum(durations),
        "objects_returned_total": sum(result_counts),
        "issue_signals": issue_signals,
        "note": "Issue signals are review candidates and do not modify the skill or DWG.",
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
