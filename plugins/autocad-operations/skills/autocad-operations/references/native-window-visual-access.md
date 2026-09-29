# Visual access to an open AutoCAD window

Use this when the task needs a view of the live desktop AutoCAD drawing. Object reads or a window title alone do not prove that the drawing is visually accessible.

1. Read the **currently installed** `computer-use` skill and its Windows guidance/API before using the UI. Check the available Computer Use surface first; its capabilities can change between sessions or versions.
2. If the available surface lists only browser tabs or returns `apps: []`, treat that as a limitation of that surface. It does not prove AutoCAD is closed or all Computer Use is unavailable. Likewise, record a CAD plugin's `Could not find window for autocad` error as a failure of that screenshot path only.
3. When the installed Computer Use skill supports the native `@oai/sky` entry point, initialize it in its prescribed persistent JavaScript tool, call `sky.list_windows()`, and select **exactly one** returned AutoCAD window by its current title and drawing name. Do not reuse a saved window ID or assume a drawing from a previous session is still open.
4. Call `sky.get_window_state({ window, include_screenshot: true })`. If it reports that the window is minimized, call `sky.activate_window({ window })`, refresh the returned window with `sky.get_window({ id: window.id, app: window.app })`, and capture again. Inspect the displayed screenshot. These steps restored visual access in a Windows/AutoCAD 2023 check; the drawing title, window ID, and tool version are session-specific.
5. Confirm the screenshot shows the intended DWG and relevant view. A full-drawing overview proves visual access but does not resolve small text or line connections; zoom to the task's region and combine visual evidence with object-level checks when topology matters.

Keep the action read-only unless the user authorized UI edits. If native capture still fails, record the exact error, current title, window inventory, and Computer Use version, then use the issue-learning workflow. Do not repeatedly restart apps or substitute guessed handles and stale coordinates.
