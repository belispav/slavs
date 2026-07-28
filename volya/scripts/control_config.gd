extends Resource
class_name ControlConfig

## All control tunables in one place (SPEC B4).
## Every distance is in MILLIMETRES — never pixels. TouchController converts
## them using the real screen DPI, so the controls feel identical on any phone.

## Upward thumb travel required to jump when the thumb is exactly above the anchor.
@export_range(2.0, 25.0, 0.1) var j0_mm: float = 9.0

## Steepness of the "windshield wiper" arc: J(dx) = j0_mm + k_arc * dx^2.
## 0.012 adds ~7.5 mm of required travel at 25 mm sideways.
@export_range(0.0, 0.05, 0.001) var k_arc: float = 0.012

## How far back down (below the arc) the thumb must drag to re-arm the jump.
@export_range(0.5, 10.0, 0.1) var hysteresis_mm: float = 2.0

## Sideways movement smaller than this is ignored (micro-jitter).
@export_range(0.0, 6.0, 0.1) var run_deadzone_mm: float = 1.5

## Sideways offset that produces full run speed.
@export_range(3.0, 30.0, 0.5) var run_saturation_mm: float = 11.0

## Minimum right-stick deflection before auto-fire engages.
@export_range(0.5, 12.0, 0.1) var aim_deadzone_mm: float = 2.5


## The arc threshold curve, in millimetres (SPEC B2).
func jump_threshold_mm(dx_mm: float) -> float:
	return j0_mm + k_arc * dx_mm * dx_mm
