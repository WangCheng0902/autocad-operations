# Block-local tag placement

Use this method when a text tag must sit inside a frame that is part of a rotated or scaled block reference. Do not assume the block insertion point, valve-disc center, or visible equipment center is the text-frame center.

## Read scope

1. Identify every target block reference and tag by stable handle.
2. Group references by block definition and geometry type.
3. Read each distinct block definition once. Extract only the primitives that can define the tag frame.
4. Determine the frame's local center, long-axis angle, usable length, and usable height.
5. Reuse that local geometry for references of the same unchanged block definition. Invalidate it after a block redefinition, explode, nonuniform scale, or unknown external edit.

This normally requires L2 for the target index and L3 for one representative definition of each block type. A drawing-wide L4 read is unnecessary unless target completeness cannot otherwise be proved.

## Coordinate transform

For a block reference with insertion point `I=(Ix,Iy)`, uniform scale `s`, rotation `r`, and a frame center `C_local=(cx,cy)`:

```text
Cx = Ix + s * (cos(r)*cx - sin(r)*cy)
Cy = Iy + s * (sin(r)*cx + cos(r)*cy)
frame_angle = normalize(r + local_axis_angle)
```

Use the transformed frame center for layout. If the CAD interface creates left-baseline text rather than centered text, estimate the initial insertion point from the frame center:

```text
text_width ~= width_factor * text_height * character_count
insertion = frame_center
          - axis_unit * text_width/2
          - perpendicular_unit * vertical_center_factor * text_height
```

Treat `width_factor` and `vertical_center_factor` as style-dependent calibration values. Validate them on one sample per block type before a batch. Do not promote values learned from one font or text style into a universal constant.

## Text size selection

- Derive an upper bound from both usable frame length and height.
- Reserve visible margins on every side; a tag fitting mathematically is not sufficient.
- Use one consistent height per block/frame type unless the drawing standard requires otherwise.
- When the user asks for a small increase, change the height in a bounded increment and recenter the text; scaling around a left-baseline insertion point alone will shift the visual center.

## Bounded write workflow

1. Create a compliant backup for an authorized formal WORK before a high-risk batch.
2. Correct one representative tag for each distinct block/frame type.
3. Verify position, readable direction, size, layer, text value, and collision clearance.
4. After user or visual confirmation, compute every target from its own current insertion point, scale, and rotation.
5. Prefer an explicit block-handle-to-tag mapping. Create or transform the batch in one bounded operation.
6. Normalize rotation to the range accepted by the interface. Some MCP operations reject negative angles; use the equivalent `0-360` degree value.
7. Save the authorized WORK and immediately re-read the changed target set.

## Verification

At minimum verify:

- expected tag count, unique values, layer, and new handles;
- every intended block handle has exactly one mapped tag;
- old handles or old-value residue are absent when tags were rebuilt;
- representative round/polygon or other geometry classes remain centered in their frames;
- unrelated accessory blocks and source geometry are unchanged;
- visual clearance and readable direction in AutoCAD.

Object checks prove counts and properties, not appearance. If screenshot or native-window capture fails, record a `VIS` or `CONN` issue, keep the batch bounded, and require a user-visible AutoCAD check before treating visual QA as complete.

## Recovery and known failure modes

- Wrong position but correct rotation: the frame local center was probably replaced with the block insertion point or equipment center.
- Correct center but wrong direction: the definition's local frame angle was omitted or added with the wrong sign.
- Larger text drifts out of the frame: it was scaled about a baseline insertion point without recomputing the centered insertion.
- Negative rotation rejected: normalize to the equivalent positive degree value.
- Offline DWG read disagrees with the active session after a reported save: do not silently trust either result. Record a `SAVE` or `VERIFY` issue, verify the active handles, and resolve persistence before delivery.
- Native screenshot unavailable: do not guess screen coordinates. Continue object-level checks and request a visible AutoCAD inspection.

## Validated calibration example

One controlled run established the method on two distinct accessory block definitions:

- round accessory: local frame center approximately `(-4.4568,-7.2910)`, local long axis approximately `-32.95 degrees`;
- polygon accessory: local frame center approximately `(1.2203,8.7972)`, local long axis approximately `-3.077 degrees`.

The user visually confirmed sample position and direction before the full batch. Text heights were then increased to `2.1` for round frames and `2.6` for polygon frames. These numbers are a case calibration, not a general drawing standard.
