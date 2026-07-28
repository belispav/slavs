# VOLYA — Control System: Specification + Implementation Addendum

Single source of truth for the two-thumb "Zero Thumb-Lifting" control scheme. Part A is the original design spec (verbatim). Part B is the technical addendum for implementation in Godot 4. Part C defines acceptance criteria for the F1 GO/NO-GO milestone.

---

## PART A — Original design specification

### Core Philosophy: Zero Thumb-Lifting

The primary goal of this control scheme is to allow the player to move, aim, shoot, and jump simultaneously without ever lifting either thumb from the screen. It achieves this by treating the "Jump" command not as a button press, but as a spatial zone.

### The Setup

- **Right Thumb (Aiming & Combat):** Manages a virtual joystick dedicated to aiming. Auto-attack is engaged while aiming.
- **Left Thumb (Movement & Jumping):** Manages horizontal movement *and* vertical jumping via a Continuous Y-Axis Threshold (an "Up-to-Jump" Virtual Joystick).

### How the Left Thumb Works

The left half of the screen is invisibly split into two horizontal regions: a bottom "Run Zone" and an upper "Jump Zone."

1. **Running:** As long as the left thumb slides left and right within the lower threshold, the character runs.
2. **Jumping:** When the left thumb slides upward past the invisible threshold line into the upper zone, the character instantly jumps.
3. **Mid-Air Control:** While the thumb is in the upper "Jump Zone," sliding left and right steers the character's trajectory in the air.
4. **Landing:** To return to ground movement (and to prepare for a subsequent jump), the thumb must slide back down into the lower "Run Zone."

### Critical UX Requirements

1. **The "Windshield Wiper" Arc Boundary.** The thumb pivots in an arc, not a straight line. The Run/Jump threshold must be a **curved arch** (higher at the far left/right) to grant vertical forgiveness at the extremes.
2. **State Reset / Jump Delay.** Landing while the thumb is still in the Jump Zone must NOT trigger a second jump. The player must drag back down into the Run Zone to re-arm the jump. The required downward distance must be extremely short.
3. **Dynamic Center Point (Floating Anchor).** The point where the thumb first touches down becomes the center of the Run Zone; the curved threshold is drawn relative to (slightly above) that point.

---

## PART B — Implementation addendum (Godot 4)

### B1. Input architecture

- Use `InputEventScreenTouch` (press/release) and `InputEventScreenDrag` (motion). Track touches by `event.index`.
- Ownership by origin: a touch that BEGAN on the left half of the screen belongs to the movement controller for its whole lifetime; a touch that began on the right half belongs to the aim controller — even if it later crosses the midline.
- All distances in **millimeters**, converted via `DisplayServer.screen_get_dpi()` (px = mm × dpi / 25.4). Never hardcode pixels — this is what makes it feel identical on every phone.
- Implement as an autoload/CanvasLayer `TouchController` emitting signals: `move_input(x: float)` (−1..1), `jump_pressed`, `air_steer(x: float)`, `aim_input(dir: Vector2, active: bool)`. Gameplay code never reads raw touches.

### B2. Left thumb — state machine

States: `NO_TOUCH` → `GROUNDED_INPUT` → `JUMP_HELD` (→ back via re-arm).

- **On touch down (left half):** store `anchor = touch_pos`. State = `GROUNDED_INPUT`.
- **GROUNDED_INPUT:** `dx = touch.x − anchor.x`; run velocity = `clamp(dx / RUN_SATURATION_MM, −1, 1)` with dead zone `RUN_DEADZONE_MM`. Check jump condition each drag event.
- **Jump condition (arc threshold):** jump fires when the thumb's upward travel exceeds the arc:
  `anchor.y − touch.y > J(dx)` where `J(dx) = J0_MM + K_ARC × dx²` (dx in mm). The quadratic gives the "windshield wiper" forgiveness — the farther sideways the thumb is, the more upward travel is required.
- **On jump fire:** emit `jump_pressed` ONCE, state = `JUMP_HELD`.
- **JUMP_HELD:** `dx` steers air trajectory (`air_steer`). A second jump is impossible in this state (single jump; if a double-jump upgrade exists later, it re-uses the same re-arm rule).
- **Re-arm:** state returns to `GROUNDED_INPUT` only when `anchor.y − touch.y < J(dx) − HYSTERESIS_MM` (a short drag down). Hysteresis prevents flutter at the boundary.
- **On touch up:** state = `NO_TOUCH`, movement input → 0 (character stops with a short decel, no slide).
- Landing does nothing to the input state — re-arm is purely a thumb gesture, per spec A2.

### B3. Right thumb — aim & auto-fire

- Floating anchor identical to left: touch-down point = stick center.
- `aim_vector = touch_pos − anchor`; active (auto-fire ON) when `|aim_vector| > AIM_DEADZONE_MM`; direction = normalized vector (free 360° aim; snap assist optional later, off by default).
- Releasing the thumb stops firing; last aim direction is retained for character facing.

### B4. Starting tunables (exported vars, single config resource `ControlConfig.tres`)

| Constant | Start value | Meaning |
|---|---|---|
| `J0_MM` | 9.0 | Upward travel to jump at dx = 0 |
| `K_ARC` | 0.012 /mm | Arc steepness (≈ +7.5 mm extra at dx = 25 mm) |
| `HYSTERESIS_MM` | 2.0 | Drag-down below threshold to re-arm |
| `RUN_DEADZONE_MM` | 1.5 | Ignore micro-jitter |
| `RUN_SATURATION_MM` | 11.0 | dx for full run speed |
| `AIM_DEADZONE_MM` | 2.5 | Min stick deflection to fire |

These are guesses to be tuned on-device in F1 — that is the point of F1.

### B5. Debug overlay (build this FIRST)

A toggleable overlay drawing: both anchors, the live arc threshold curve `y = anchor.y − J(dx)`, current touch points, state labels, and a rolling counter of jumps fired. Without visualization, tuning the arc blind is guesswork. Add three on-screen sliders (J0, K_ARC, HYSTERESIS) in the debug build so tuning happens live on the phone without rebuilds.

### B6. Edge cases

- Multi-touch index reuse after release (Android reuses indexes — always key state by index AND check press/release transitions).
- Both first touches on the same half: second touch is assigned to the unclaimed controller.
- Touch drifting off-screen / app losing focus: treat as touch-up, zero all inputs, pause game on focus loss.
- Ignore touches while game is paused; swallow the unpause tap so it doesn't fire a jump.

---

## PART C — F1 acceptance criteria (GO/NO-GO)

Test scene: flat ground + 3 platforms + moving dummy targets. Gray boxes, no art.

1. 10 minutes of continuous play by Pavel: **zero unintended jumps** and zero missed intended jumps (self-reported, counter-assisted).
2. Jump fires within one frame of threshold crossing (no perceptible latency).
3. Run → jump → air-steer → land → re-arm → jump again, all without lifting either thumb, feels fluid at the far left and far right thumb extension (arc test).
4. Auto-fire tracks aim at 360° while running and jumping simultaneously.
5. Same feel on at least 2 physical devices with different screen sizes/DPI (mm-based tuning verified).

If criteria 1–3 cannot be reached after tuning, STOP and redesign controls before any further investment (per plan §5, F1 is the Go/No-Go gate of the whole project).
