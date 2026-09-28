# Issue logging and controlled learning

## Create an issue when

- an MCP call fails, times out, returns no data, or returns incomplete data;
- an unchanged retry repeats without progress;
- a target is ambiguous or an expected object is missing;
- post-write verification disagrees with the reported result;
- visual and object evidence conflict;
- the read scope is materially larger than the task requires;
- the user identifies a misread, missed edit, wrong edit, or wrong engineering direction;
- rollback, undo, reopen, or a fallback path is required.

## Categories

Use `CONN`, `READ`, `LOC`, `VIS`, `WRITE`, `SAVE`, `VERIFY`, `PERF`, `SAFE`, or `TOOL`. Suggested ID: `{CATEGORY}-{YYYYMMDD}-{SEQ}`.

## Learning states

- `OBSERVED`: symptom recorded; cause uncertain.
- `CANDIDATE`: a bounded solution is proposed.
- `VALIDATED`: the original task passes object and required visual checks.
- `PROMOTED`: the rule passes at least one additional representative case and the regression set.
- `REJECTED`: the solution fails or creates unacceptable risk.
- `SUPERSEDED`: a better validated rule replaces it.

Do not use an `OBSERVED` or `CANDIDATE` workaround as a default DWG write rule.

## Candidate requirements

Record the symptom, evidence, affected handles, root-cause confidence, resolution steps, applicability, exclusions, verification, rollback, and before/after metrics. Prefer narrower reads or stronger disambiguation without weakening safety.

## Promotion gate

A candidate may be promoted only when the original case and another representative case pass, unrelated objects remain unchanged, current rules stay satisfied, a measurable improvement exists, failure fallback is defined, and relevant regression cases pass.

Changes to engineering standards, destructive actions, broad write scope, backup behavior, or user authorization always require explicit user direction.

## End-of-task review

Check for errors, retries, rollback, user correction, excessive reads, and a reusable solution. Add an issue only when evidence exists. A clean run needs metrics, not an invented lesson.

For a foreign-DWG compatibility warning, record the producer warning, one-time continue decision, whether the global suppression option remained clear, read-only verification results, and whether the original source remained unchanged.

For a native-window control failure, record the app inventory result, whether runtime reset and one discovery retry were attempted, the exact blocked action, and the safe handoff or non-UI fallback. Do not substitute guessed window handles, stale screenshot coordinates, or an ungoverned UI automation method.

## Validated candidates awaiting promotion

### 跨DWG插入块前显式设置目标图层

- State: `CANDIDATE`; validated on one controlled AUX-to-WORK insertion case only.
- Symptom: a DWG inserted as a block reference inherits the target drawing's current layer, which may be an unrelated annotation layer such as `TEXT`.
- Candidate rule: before `-INSERT`, explicitly set `CLAYER` to the intended block-reference layer; after insertion, verify the new reference handle, layer, X/Y/Z scales, rotation, block name, and definition entity count.
- Recovery: discard the uncommitted temporary result and regenerate from the verified pre-insertion baseline; do not merely assume the layer can be corrected later without checking dependent visibility behavior.
- Promotion gate: reproduce and validate on another cross-DWG insertion case.

### Core Console缺少桌面COM或布局辅助函数时的模板复制核验

- State: `CANDIDATE`; validated on one controlled WORK creation case only.
- Symptom: `vlax-get-acad-object` returns `nil` in Core Console and `layoutlist` is unavailable, so a desktop-COM layout enumeration script cannot run.
- Candidate fallback: compare source and target file hashes immediately after copying; create a transient verification copy of the target; reopen only that copy through Core Console; compare `CTAB`, model-space counts, key entity-type counts, extents, and `DBMOD`; add a full-extents visual preview; finally recheck the untouched source and target hashes.
- Exclusions: this fallback does not prove complete paper-space or viewport equivalence. Use a layout-table-capable object interface when the task specifically requires layout auditing.
- Promotion gate: repeat on another controlled template-copy case and retain a layout-aware verification path for layout-sensitive drawings.

### Core Console“只读复开”仍可能改变DWG文件级元数据

- State: `CANDIDATE`; validated on one controlled WORK creation case only.
- Symptom: Core Console reports `DBMOD=0` before and after inspection, but the inspected DWG's hash and write time change while file length, entity counts, extents, and visible content remain stable.
- Candidate rule: do not run Core Console verification directly on a protected template or a byte-identical newly created WORK when exact binary preservation matters. Verify a transient copy instead, then compare the untouched template and WORK hashes.
- Recovery: restore a protected tracked template only from a verified controlled source whose hash matches the pre-operation baseline; recreate the new WORK from the same bytes; confirm the template's version-control status is clean.
- Exclusions: a clean `DBMOD` does not prove byte-for-byte immutability. Do not restore from version control when the pre-operation template had uncommitted user changes or when its baseline identity is uncertain.
- Promotion gate: reproduce on another AutoCAD/Core Console file and determine whether preview, access metadata, or another header field is responsible.

### 缩小或反向缩放后的图形范围缓存重算

- State: `CANDIDATE`; validated on one controlled AUX integer-scale test only.
- Symptom: after geometry is inversely scaled back, representative entities have restored coordinates and sizes, but `EXTMIN`/`EXTMAX` temporarily retain the enlarged range.
- Candidate sequence: verify representative entity geometry first; run Zoom Extents to force an extent recalculation; then read `EXTMIN`/`EXTMAX` and compare against the baseline.
- Exclusions: do not use extent recovery alone as proof that every entity was restored; object count and representative handles must also pass.
- Promotion gate: reproduce and resolve the same cache behavior on another representative scale or move test.

### Core Console中文路径DWG原位保存失败时的受控`SAVEAS`回写

- State: `CANDIDATE`; validated on one controlled AUX annotation-cleanup case only.
- Symptom: object deletion is visible in-session, but after `QSAVE`, `DBMOD` remains 1, the file timestamp does not change, and reopening restores the original object count.
- Candidate sequence: stop unchanged retries; `SAVEAS` to a pure-English temporary path; reopen that file; verify object counts, required entity types, `DBMOD=0`, and a full-extents visual; close the exact occupied target drawing through CAD file management; replace only the prechecked AUX target; reopen the official AUX and repeat verification.
- Applicability: controlled AUX/WORK edits where the exact destination is known and the source or formal input DWG must remain unchanged.
- Exclusions: do not overwrite `SRC` or `REL`; do not use when the target identity is ambiguous, when unsaved unrelated user changes may exist, or when naming rules require preserving multiple versions.
- Promotion gate: pass one additional representative Chinese-path save case, prove unrelated objects remain unchanged, and retain the original in-place-save failure as a regression test.

### AutoCAD 2023 `-WBLOCK` object extraction prompt sequence

- State: `CANDIDATE`; validated on one controlled local-plan extraction case only.
- Symptom: after the output path, AutoCAD 2023 prompts for an existing block name or a new drawing definition before it accepts the base point.
- Candidate sequence: output path, empty response for a new drawing definition, base point, stable selection set, end selection.
- Verification required: reopen the output, compare expected and actual object counts, confirm the source was not saved, and inspect a representative full-extents view.
- Exclusions: do not assume the same prompt order across AutoCAD releases, localized variants, or wrappers; detect or test the prompt sequence before reusing it.
- Promotion gate: pass one additional representative extraction case with no unrelated objects and a verified fallback.

### 活动AutoCAD会话中异步`PNGOUT`进入交互等待

- State: `CANDIDATE`; validated on one controlled outer-main visual-verification case only.
- Symptom: COM `SendCommand` starts `PNGOUT` in the active desktop session, but the command remains at an interactive prompt; later calls report AutoCAD busy or `RPC_E_CALL_REJECTED`, and no trustworthy screenshot is produced.
- Candidate rule: when Computer Use cannot return the exact AutoCAD window, do not run unattended interactive export in the active session. Save the authorized WORK, copy it to a simple temporary path, and run a fully specified SCR through Core Console against only that temporary copy.
- Recovery: stop retries; press Esc in AutoCAD; confirm `CMDACTIVE=0`; save only after the command has ended; then use the temporary-copy export path and visually inspect the PNG.
- Exclusions: do not assume Core Console output proves desktop UI state, loaded external references, or plotted lineweight appearance. Do not run the fallback directly on a protected SRC or byte-sensitive WORK.
- Verification: the controlled correction produced a readable PNG from a temporary copy while the official WORK remained the active engineering file; project identifiers and exact geometry are intentionally excluded from this public rule.
- Promotion gate: repeat on another representative DWG and confirm the scripted export neither changes the protected drawing nor omits task-critical referenced geometry.

### 粗环形气源管主管误用阀门圈半径定位

- State: `CANDIDATE`; corrected on one wide-pipe centerline case; awaiting another representative case.
- Symptom: the main was moved outside the valve circle but still did not lie in the middle of the visibly wide outer gas pipe.
- Root cause: “outermost” was interpreted relative to the valve arrangement instead of deriving the centerline from the actual inner and outer pipe boundaries.
- Candidate rule: read the two verified boundaries of the same pipe band; when they are concentric, use their common center and the mean radius. Derive opening angles from the pipe boundary geometry, then extend branch outer endpoints to that centerline while preserving verified inner endpoints.
- Evidence retained publicly: two verified concentric boundaries produced the expected mean-radius centerline; exact project geometry is intentionally excluded.
- Exclusions: do not average unrelated shell arcs, interrupted accessories, reinforcement rings, or arcs with materially different centers. For non-concentric pipe boundaries, use a local offset/medial construction rather than one global average radius.
- Recovery: restore the pre-change backup if the boundary pair is later disproved; otherwise replace only the main and its six branch-side endpoints, then verify all seven objects and obtain a clear visual view.
- Promotion gate: pass a second representative wide-pipe case and confirm centerline placement visually without changing unrelated objects.

### 展开流程图按最近支管轴线归组产生串组

- State: `CANDIDATE`; validated on one controlled multi-branch unfolded-diagram case only.
- Symptom: terminal tags extending toward the adjacent branch are geometrically closer to the neighboring vertical axis, so nearest-axis classification reports incorrect branch and side counts.
- Root cause: the unfolded diagram uses staggered upper/lower terminal slots, and terminal reach can exceed part of the spacing between adjacent branch axes.
- Candidate rule: classify by a verified slot model combining branch order, side, vertical level, terminal-block association, and stable handles. Treat nearest-axis distance only as a candidate-generation aid, never as the final branch identity when terminal extents overlap adjacent groups.
- Stop condition: if the resulting per-branch matrix does not equal the approved near/far/spare counts, do not write tags.
- Verification: the controlled case used an explicit handle set; the final tag set had no missing values, duplicates, or obsolete-prefix residue, and the terminal matrix matched the approved design counts.
- Promotion gate: reproduce on another unfolded multi-branch diagram with overlapping horizontal terminal extents.
