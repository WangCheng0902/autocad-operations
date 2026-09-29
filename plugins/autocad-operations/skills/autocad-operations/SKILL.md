---
name: autocad-operations
description: Inspect, modify, and verify AutoCAD engineering drawings through MCP or computer use with task-scoped DWG reads, object-level checks, and structured issue logging. Use for CAD object queries, tag or annotation edits, branch and topology checks, drawing-wide audits, or improvement of repeated CAD workflows.
---

# AutoCAD Operations

Use the smallest sufficient read scope that can support a correct and verifiable result. Treat the current AutoCAD document and DWG state as external state: verify them before reusing prior object data.

## Route the task

1. Confirm the active drawing, path, layout, space, save state, and task authorization.
2. Classify the task as object/attribute, spatial, topology, visual/layout, or drawing-wide verification.
3. Read [references/adaptive-reading.md](references/adaptive-reading.md) to select the read level and cache policy.
4. For a write operation or a task involving both MCP and UI interaction, read [references/operation-and-verification.md](references/operation-and-verification.md).
5. When a tool fails, a correction is required, or the workflow is inefficient, read [references/issue-learning.md](references/issue-learning.md) and record observable facts.
6. For text placed inside an offset or rotated region of a block, read [references/block-local-tag-placement.md](references/block-local-tag-placement.md). Use it for valve-tag frames, equipment labels, and similar block-relative annotations.
7. For installation, MCP registration, readiness states, or repeated upgrades, read [references/installation-and-diagnostics.md](references/installation-and-diagnostics.md).
8. For a visual check of an open AutoCAD window, or when a screenshot path cannot find that window, read [references/native-window-visual-access.md](references/native-window-visual-access.md). Verify success from the actual image, not merely from a window listing.

## Required invariants

- Never identify a CAD object only by screen coordinates or non-unique text when a handle, layer, region, or association can disambiguate it.
- Do not treat remembered data, a prior screenshot, or a previous tool response as proof of the current DWG state.
- Keep reads scoped; expand them only when candidates remain ambiguous or the task requires global topology or completeness.
- Before writing, record target handles or an equivalent stable target set and the expected changes.
- After writing, re-read changed objects and verify the relevant neighborhood or global constraint.
- Separate object-data evidence, visual evidence, reference-document evidence, and user-confirmed facts.
- Do not promote a newly observed workaround into a default write rule. Record it as a candidate and require validation first.
- Preserve the user's authorization boundary. Reading or learning from a task does not authorize extra edits, saves, backups, deletions, or publication.

## Issue logging

When the project permits an operation log, use `scripts/record_cad_event.py` with an explicitly chosen JSONL path. Record tool names, sanitized arguments, status, duration, affected handles, verification results, and concise error facts. Do not record hidden reasoning, credentials, or unnecessary full-object dumps.

Use `scripts/summarize_cad_run.py` to generate a metrics summary from a run log. A summary may propose candidates; it must not edit this skill or a DWG automatically.

## Finish

Report the DWG actually inspected or changed, the read scope used, the objects changed, the verification performed, unresolved risks, and any recorded issue ID. If no reusable problem occurred, do not invent an improvement item.
