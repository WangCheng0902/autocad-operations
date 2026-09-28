---
name: autocad-operations
description: Inspect, modify, and verify AutoCAD engineering drawings through MCP or computer use with task-scoped DWG reads, object-level checks, visual evidence, and structured issue logging. Use for CAD object queries, annotation edits, topology checks, drawing audits, or repeated workflow improvement.
---

# AutoCAD Operations

Use the smallest sufficient read scope that supports a correct and verifiable result. Treat the active AutoCAD document and DWG state as external state and verify them before reusing earlier object data.

## Environment gate

1. Confirm the supported environment or report a degraded mode. Version 0.1 formally targets Windows 11, AutoCAD 2023, and Codex desktop.
2. Check whether an AutoCAD object interface is available before promising object reads or writes.
3. Check whether Computer Use returns the exact AutoCAD window before promising UI actions or visual evidence.
4. If a capability is unavailable, continue only within the remaining evidence boundary and state the limitation.

## Route the task

1. Confirm the active drawing, path, layout, space, save state, and task authorization.
2. Classify the task as object/attribute, spatial, topology, visual/layout, or drawing-wide verification.
3. Read only the objects and neighborhoods needed to disambiguate the requested change.
4. Before writing, record target handles or an equivalent stable target set and expected changes.
5. After writing, re-read changed objects and verify the relevant neighborhood or global constraint.
6. Separate object-data evidence, visual evidence, reference-document evidence, and user-confirmed facts.

## Required invariants

- Never identify a CAD object only by screen coordinates or non-unique text when a handle, layer, region, or association can disambiguate it.
- Do not treat remembered data, a prior screenshot, or an earlier tool response as proof of the current DWG state.
- Preserve the user's authorization boundary. A read or diagnostic request does not authorize edits, saves, backups, deletion, or publication.
- Do not describe object checks as visual verification.
- Do not promote a newly observed workaround into a default rule until it is independently reproduced and reviewed.
- Do not embed personal paths, credentials, project-sensitive tags, or DWG content in shared plugin resources or logs.

## Issue learning

For a failed tool call, required correction, repeated inefficiency, or useful workaround, record observable facts: environment, action, error, affected objects, recovery, verification, and remaining uncertainty. Summaries may propose candidate rules but must not automatically rewrite this skill or a DWG.

## Finish

Report the DWG actually inspected or changed, read scope, changed objects, verification performed, degraded capabilities, unresolved risks, and any recorded issue identifier.
