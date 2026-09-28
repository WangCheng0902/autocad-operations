#!/usr/bin/env python3
"""Report autocad-operations runtime readiness without modifying the system."""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


def command_ok(command: list[str]) -> tuple[bool, str]:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=20, check=False)
        detail = (result.stdout or result.stderr).strip()
        return result.returncode == 0, detail[:1000]
    except Exception as exc:  # diagnostic boundary
        return False, f"{type(exc).__name__}: {exc}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--multi-cad", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    windows_11 = platform.system() == "Windows" and int(platform.version().split(".")[2]) >= 22000
    acad_root = Path(os.environ.get("ProgramFiles", r"C:\Program Files")) / "Autodesk" / "AutoCAD 2023"
    acad = acad_root / "acad.exe"
    core_console = acad_root / "accoreconsole.exe"
    python_ok = sys.version_info >= (3, 10)
    codex_path = shutil.which("codex")
    git_path = shutil.which("git")
    mcp_ok, mcp_detail = command_ok([codex_path, "mcp", "get", "multicad", "--json"]) if codex_path else (False, "codex not found")
    plugin_ok, plugin_detail = command_ok([codex_path, "plugin", "list", "--json"]) if codex_path else (False, "codex not found")
    multi_cad = args.multi_cad.resolve() if args.multi_cad else None
    multi_cad_ok = bool(multi_cad and (multi_cad / "pyproject.toml").is_file() and (multi_cad / "src" / "server.py").is_file())

    if windows_11 and acad.is_file() and python_ok and codex_path and git_path and multi_cad_ok and mcp_ok:
        state = "DEGRADED_OBJECT_ONLY"
        note = "Object tooling is configured. Computer Use must be checked inside Codex before visual automation."
    elif windows_11 and python_ok and codex_path:
        state = "DEGRADED_GUIDANCE_ONLY"
        note = "Core dependencies are incomplete; do not claim CAD object operations."
    else:
        state = "BLOCKED"
        note = "The supported Windows/Codex/Python baseline is not satisfied."

    report = {
        "schema_version": "1.0",
        "state": state,
        "note": note,
        "platform": platform.platform(),
        "python": sys.version.split()[0],
        "checks": {
            "windows_11": windows_11,
            "python_3_10_plus": python_ok,
            "git": git_path,
            "codex": codex_path,
            "autocad_2023": str(acad) if acad.is_file() else None,
            "core_console": str(core_console) if core_console.is_file() else None,
            "multi_cad_source": str(multi_cad) if multi_cad else None,
            "multi_cad_source_valid": multi_cad_ok,
            "multicad_mcp_registered": mcp_ok,
            "plugin_list_available": plugin_ok,
        },
        "details": {"mcp": mcp_detail, "plugins": plugin_detail},
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if state != "BLOCKED" else 2


if __name__ == "__main__":
    raise SystemExit(main())
