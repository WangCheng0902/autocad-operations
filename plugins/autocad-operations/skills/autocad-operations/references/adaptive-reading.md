# Adaptive DWG reading

Choose the lowest sufficient level, then expand only when evidence is incomplete.

|Level|Read scope|Use|
|---|---|---|
|L0|Active document, path, file state, layout, space|Every task|
|L1|Layers, object counts, blocks, references, extents|Drawing orientation and query planning|
|L2|Handles, types, layers, bounding boxes, text/block summaries|Search, indexing, batch identification|
|L3|Full target properties, geometry, neighbors, local view|Edits and local engineering checks|
|L4|Full drawing details and global relationships|Global topology, uncertain state, delivery audit|

## Task routing

- Single text or tag edit: `L0`, index lookup, then `L3` for the target and neighborhood.
- Batch tag replacement: `L0`, `L2` for text and attributes, then `L3` for all matched targets.
- Branch near/far classification: `L0`, `L1`, `L3` for inlet, connection, branch geometry, valve centers, and a supporting view.
- Notes: `L0`, `L3` for the note region and the relevant source excerpt.
- Layer/color/linetype changes: `L0`, `L1`, `L2` for the target property set; expand geometry only if spatial meaning matters.
- Connectivity or topology: `L0` through `L3`; use `L4` when the system boundary is unknown.
- Layout or printing: `L0`, layout/viewport data, and a visual preview.
- Delivery audit: drawing-wide `L2`, targeted `L4`, and visual checks.

## Query order

Prefer handles, exact text or block attributes, layer and object type, bounding box, neighborhood, intersections, topology, then business group. Combine filters to remove ambiguity.

## Cache policy

Reuse an index only when the drawing identity, state, index schema, and required fields are verifiable. Invalidate only changed handles and their neighborhood after a known local edit. Rebuild the lightweight index after unknown external edits, large transforms, block redefinitions, reference changes, format conversions, repair operations, or before a delivery audit.

Use handles as persistent keys within the same DWG. Treat ObjectID as session-scoped. Verify handles after save-as, insertion, binding, explode, block redefinition, or conversion.

## Stop and expand conditions

Stop reading when the candidate set is unique and evidence is sufficient. Expand when results are non-unique, an expected object is missing, object data conflicts with the view, the system boundary is unclear, or a global completeness claim is required.
