extends Resource
class_name ControlConfig

## All control tunables in one place (SPEC B4).
## Every distance is in MILLIMETRES — never pixels. TouchController converts
## them using the real screen DPI, so the controls feel identical on any phone.

## Upward thumb travel required to jump when the thumb is exactly above the anchor.
@export_range(2.0, 25.0, 0.1) var j0_mm: float = 9.0

## Curvature of the "windshield wiper" threshold: J(dx) = j0_mm + k_arc * dx^2.
##
## NEGATIVE = dome (correct default). The thumb pivots around its joint, so when
## it is extended sideways it physically cannot reach as far up — the threshold
## must DROP at the extremes. -0.012 removes ~7.5 mm of required travel at
## 25 mm sideways, which matches a thumb pivot radius of about 40 mm.
##
## POSITIVE = valley (more travel required at the extremes). Kept reachable on
## the slider so the shape can be compared on-device instead of argued about.
@export_range(-0.04, 0.04, 0.001) var k_arc: float = -0.012

## Hard floor for the threshold, so the dome can never reach zero and fire
## jumps by itself at full sideways extension.
@export_range(1.0, 10.0, 0.1) var j_min_mm: float = 3.0

## How far back down (below the arc) the thumb must drag to re-arm the jump.
@export_range(0.5, 10.0, 0.1) var hysteresis_mm: float = 2.0

## Sideways movement smaller than this is ignored (micro-jitter).
@export_range(0.0, 6.0, 0.1) var run_deadzone_mm: float = 1.5

## Sideways offset that produces full run speed.
@export_range(3.0, 30.0, 0.5) var run_saturation_mm: float = 11.0

## Minimum right-stick deflection before auto-fire engages.
@export_range(0.5, 12.0, 0.1) var aim_deadzone_mm: float = 2.5

## Max distance the aim thumb may get from its anchor before the anchor slides
## after it. Small value = the stick stays under the thumb, so turning around
## takes a short flick instead of dragging across the whole anchor.
@export_range(3.0, 30.0, 0.5) var aim_recenter_mm: float = 9.0


## The arc threshold curve, in millimetres (SPEC B2).
func jump_threshold_mm(dx_mm: float) -> float:
	return maxf(j0_mm + k_arc * dx_mm * dx_mm, j_min_mm)
