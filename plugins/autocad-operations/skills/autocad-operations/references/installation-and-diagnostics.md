# Installation and diagnostics

Use this reference when diagnosing plugin installation, MCP registration, or repeated upgrades.

## Boundaries

- Use the repository `install.ps1` instead of manually editing Codex TOML.
- Back up the current Codex configuration before replacing an MCP entry.
- Treat a Marketplace source as either local or Git-backed. Do not call a Git-only upgrade operation for a local Marketplace.
- Reusing a local Marketplace is valid only when its resolved root equals the current repository root.
- If the same Marketplace name points to another root, require confirmation before removing and re-adding it.
- A successful command-line environment check proves object-tool configuration, not Computer Use access to the AutoCAD window.

## Readiness states

- `READY`: object tools and the exact AutoCAD window have both been verified in the active Codex session.
- `DEGRADED_OBJECT_ONLY`: MCP and AutoCAD are configured, but native-window visual access is unverified or unavailable.
- `DEGRADED_GUIDANCE_ONLY`: Codex can load the workflow but cannot prove live CAD object access.
- `BLOCKED`: the supported Windows, Python, Codex, or required dependency baseline is missing.

## Repeated-install failure learned during validation

- Symptom: the first installation succeeds, but a second run fails when it invokes `codex plugin marketplace upgrade` for an already configured local Marketplace.
- Cause: the upgrade command applies to Git-backed sources, while the clone-and-install workflow registers the checked-out repository as a local Marketplace.
- Fix: parse `codex plugin marketplace list --json`; reuse an entry when its resolved root matches the current repository, otherwise request confirmation before replacing it.
- Verification: run the installer twice and require both runs to finish with the same MCP command, Marketplace root, plugin version, and diagnostic state.
