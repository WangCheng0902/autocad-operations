# Operation and verification

## Tool roles

- Use MCP or an object API for handles, properties, geometry, queries, exact edits, counts, and post-write checks.
- Use computer interaction for current visual state, spatial interpretation, UI-only commands, dialogs, and final appearance.
- Use scripts for deterministic logging, comparison, metrics, or a narrowly scoped operation not exposed by MCP.

## Before a write

Confirm the active drawing, authorized target, stable target set, old and expected values, file lifecycle type, applicable backup/save rules, expected counts, and forbidden changes.

## Write behavior

- Prefer explicit handle-to-change mappings.
- When text values repeat, disambiguate by region, layer, object type, associated block, or neighborhood.
- Keep a batch bounded and inspect its result before starting another batch.
- Do not use a stale screen position after the view or UI changes.
- Treat partial success as failure until each intended target is accounted for.

## Verification scope

|Change|Minimum verification|
|---|---|
|Single text|Target, duplicates, old-value residue, local view|
|Batch tags|Every target handle, old/new counts, unrelated-region invariants|
|Properties|Target set, property distribution, representative view|
|Move|Old and new locations, collisions, associations|
|Branch|Entire branch, main connection, near/far grouping|
|Block definition|All affected references and representative views|
|Topology|Affected network, open endpoints, duplicate segments|
|Delivery change|Drawing-wide rules, layouts, key visual areas|

Report separately what was established by object data, by visual inspection, by source documentation, and by the user.

For a line intended to run through the middle of a visibly wide pipe or annular band, identify the two actual pipe boundaries first. Confirm that they describe the same band (matching center or consistent offset, compatible angular coverage, and local visual context), then construct the centerline from their geometric midpoint. Do not substitute a nearby valve-layout circle, equipment shell, fitted valve-center circle, or a screenshot-only estimate.

## Foreign DWG warning

When AutoCAD reports that a DWG was not saved by an Autodesk-developed or licensed application:

- Treat the message as a compatibility and integrity warning, not proof that the file is corrupt.
- For an authorized inspection, continue opening that specific file once.
- Keep any global “always open” or “do not show again” option cleared so future external files still receive scrutiny.
- Inspect the file read-only first. Verify drawing identity, object counts, representative objects, visual appearance, and `DBMOD` before and after inspection.
- Do not overwrite the source merely to remove the warning. If conversion is later required, create a separately authorized working copy and validate it before use.
- If UI automation cannot bind the modal, do not use guessed coordinates; ask the user to choose the one-time continue action.

Before promising a native AutoCAD UI action, verify that Computer Use returns the exact AutoCAD window or modal in its native-app inventory. If the inventory is empty, reset the Computer Use runtime and retry discovery once. When native discovery is still unavailable, stop UI automation, record a `CONN` issue, hand off only the blocking modal action to the user, and continue object-level verification through an authorized read-only interface when available.

## Visual export without a bound AutoCAD window

- Do not start interactive `PNGOUT`, `PLOT`, or another prompt-driven export in the active desktop AutoCAD session through asynchronous COM `SendCommand` when Computer Use cannot observe the window.
- If such a command is already waiting and COM reports that AutoCAD is busy or rejects calls, stop retries. Have the user press Esc, then verify `CMDACTIVE=0` before any save or further operation.
- Preferred fallback: save the authorized WORK, make a regenerable copy at a simple temporary path, run a deterministic SCR through Core Console against only that copy, export a bounded window, and inspect the resulting image. Do not use the protected WORK or SRC as the Core Console verification target.
- Archive the accepted image as `CHK`; keep the script and disposable DWG as `TMP`. Record the visible limits of the evidence, especially when the export omits UI state, external references, or lineweight display behavior.
