extends Resource
class_name ControlConfig

## All control tunables in one place (SPEC B4).
## Every distance is in MILLIMETRES — never pixels. TouchController converts
## them using the real screen DPI, so the controls feel identical on any phone.

## Upward thumb travel required to jump when the thumb is exactly above the anchor.
@export_range(2.0, 25.0, 0.1) var j0_mm: float = 9.0

## Curvature of the "windshield wiper" threshold, SEPARATE PER SIDE:
##   J(dx) = j0_mm + (dx < 0 ? k_arc_left : k_arc_right) * dx^2
##
## NEGATIVE = dome. The thumb pivots around its joint, so extended sideways it
## physically cannot reach as far up — the threshold must DROP at the extremes.
## POSITIVE = valley (more travel required at the extremes).
##
## The two sides are NOT equal: the thumb grips the phone from one side, so its
## reach up-and-inward differs from its reach up-and-outward. Measured on device
## in F1: the left side falls away far less than the right.
##
## These defaults assume the phone is held in the LEFT hand with the left thumb
## on the movement stick. A left/right-handed switch belongs in v1.0 options.
@export_range(-0.04, 0.04, 0.001) var k_arc_left: float = -0.005
@export_range(-0.04, 0.04, 0.001) var k_arc_right: float = -0.012

## Hard floor for the threshold, so the dome can never reach zero and fire
## jumps by itself at full sideways extension.
##
## F1 finding: this matters far less than expected. The anchor is wherever the
## thumb first lands, which is almost never the very bottom edge of the screen,
## so there is normally room below the dome anyway. A high floor only gets in
## the way. Measured preference: 1.0.
@export_range(0.0, 10.0, 0.1) var j_min_mm: float = 1.0

## How far back down (below the arc) the thumb must drag to re-arm the jump.
##
## F1 finding: measured preference is 0 — any required travel reads as the
## control refusing to respond. Kept as a knob because 0 removes the only
## protection against flutter at the boundary; if the jump counter starts
## showing unintended jumps, this is the first value to raise.
@export_range(0.0, 8.0, 0.1) var hysteresis_mm: float = 0.0

## Sideways movement smaller than this is ignored (micro-jitter).
@export_range(0.0, 6.0, 0.1) var run_deadzone_mm: float = 1.5

## Sideways offset that produces full run speed.
@export_range(3.0, 30.0, 0.5) var run_saturation_mm: float = 11.0

## Minimum right-stick deflection before auto-fire engages.
@export_range(0.5, 12.0, 0.1) var aim_deadzone_mm: float = 2.5

## Max distance the aim thumb may get from its anchor before the anchor slides
## after it. SMALL = fast turnaround but twitchy, because a millimetre of thumb
## jitter swings the aim a long way. LARGE = steady and precise, at the cost of
## more thumb travel per rotation. There is no CPU cost either way.
@export_range(3.0, 60.0, 0.5) var aim_recenter_mm: float = 15.0


## The arc threshold curve, in millimetres (SPEC B2). Asymmetric by design.
func jump_threshold_mm(dx_mm: float) -> float:
	var k: float = k_arc_left if dx_mm < 0.0 else k_arc_right
	return maxf(j0_mm + k * dx_mm * dx_mm, j_min_mm)
