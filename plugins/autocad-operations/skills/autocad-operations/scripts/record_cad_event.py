#!/usr/bin/env python3
"""Append one validated, structured CAD event to a JSONL run log."""

from __future__ import annotations

import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ALLOWED_EVENTS = {"run", "tool", "change", "verification", "issue", "outcome"}
ALLOWED_STATUSES = {
    "started", "success", "partial", "failed", "timeout", "unknown",
    "completed", "rolled_back",
}
FORBIDDEN_KEYS = {"password", "secret", "token", "api_key", "chain_of_thought"}


def parse_payload(raw: str) -> dict[str, Any]:
    payload = json.loads(raw)
    if not isinstance(payload, dict):
        raise ValueError("payload must be a JSON object")
    return payload


def find_forbidden_keys(value: Any, path: str = "payload") -> list[str]:
    findings: list[str] = []
    if isinstance(value, dict):
        for key, child in value.items():
            child_path = f"{path}.{key}"
            if str(key).lower() in FORBIDDEN_KEYS:
                findings.append(child_path)
            findings.extend(find_forbidden_keys(child, child_path))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            findings.extend(find_forbidden_keys(child, f"{path}[{index}]"))
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", required=True, help="Explicit output JSONL path")
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--event", required=True, choices=sorted(ALLOWED_EVENTS))
    parser.add_argument("--status", required=True, choices=sorted(ALLOWED_STATUSES))
    parser.add_argument("--payload", default="{}", help="JSON object with observable facts")
    args = parser.parse_args()

    payload = parse_payload(args.payload)
    bad_keys = find_forbidden_keys(payload)
    if bad_keys:
        raise ValueError(f"forbidden payload keys: {sorted(bad_keys)}")

    record = {
        "schema_version": "1.0",
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "run_id": args.run_id,
        "event": args.event,
        "status": args.status,
        "payload": payload,
    }
    output = Path(args.log).expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    line = json.dumps(record, ensure_ascii=False, separators=(",", ":")) + "\n"
    fd = os.open(output, os.O_APPEND | os.O_CREAT | os.O_WRONLY, 0o600)
    try:
        os.write(fd, line.encode("utf-8"))
    finally:
        os.close(fd)
    print(json.dumps({"written": str(output), "event": args.event, "status": args.status}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
