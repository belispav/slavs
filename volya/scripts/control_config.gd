extends Resource
class_name ControlConfig

## All control tunables in one place (SPEC B4).
## Every distance is in MILLIMETRES — never pixels. TouchController converts
## them using the real screen DPI, so the controls feel identical on any phone.

## Upward thumb travel required to jump when the thumb is exactly above the anchor.
@export_range(2.0, 25.0, 0.1) var j0_mm: float = 9.0

## The player's comfortable sideways thumb sweep, measured from the anchor.
## The whole threshold curve is expressed relative to THIS, not to an abstract
## coefficient — so a player with a short thumb reach gets the same shape, just
## compressed. Beyond this distance the curve stops changing.
##
## F1 finding: parameterising the curve by dx² directly was a mistake. Inside a
## real thumb sweep the quadratic is almost flat, so the curve felt "too wide"
## and intended jumps were being missed.
@export_range(5.0, 35.0, 0.5) var reach_mm: float = 12.0

## How much HIGHER the threshold sits at the far LEFT of that sweep.
## The thumb reaches up easily on the inward side, so it needs more headroom
## there or the run gesture starts firing jumps by itself.
@export_range(0.0, 20.0, 0.25) var rise_left_mm: float = 6.0

## How much LOWER the threshold sits at the far RIGHT of that sweep.
## The thumb cannot physically reach as high on the outward side, so the
## requirement must come down to meet it.
##
## Defaults assume the phone is held in the LEFT hand with the left thumb on
## the movement stick. A left/right-handed switch belongs in v1.0 options.
@export_range(0.0, 20.0, 0.25) var drop_right_mm: float = 5.0

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

## Sideways offset that produces full run speed — SEPARATE PER SIDE.
##
## F1 finding: the anchor lands where the thumb first touches, which is near
## the left edge of the screen. There is a whole screen of travel available to
## the right and only a few millimetres to the left, so demanding the same
## distance in both directions makes backing up physically impossible.
##
## Setting a value close to the dead zone makes that direction effectively
## digital (any push = full speed), which is how Metal Slug and the rest of the
## genre actually behave. That is a legitimate setting, not a degenerate one.
@export_range(2.0, 30.0, 0.5) var run_saturation_left_mm: float = 5.0
@export_range(2.0, 30.0, 0.5) var run_saturation_right_mm: float = 15.0

## Minimum right-stick deflection before auto-fire engages.
@export_range(0.5, 12.0, 0.1) var aim_deadzone_mm: float = 2.5

## Max distance the aim thumb may get from its anchor before the anchor slides
## after it. SMALL = fast turnaround but twitchy, because a millimetre of thumb
## jitter swings the aim a long way. LARGE = steady and precise, at the cost of
## more thumb travel per rotation. There is no CPU cost either way.
@export_range(3.0, 60.0, 0.5) var aim_recenter_mm: float = 15.0

## How hard the aim anchor is pulled toward the thumb when the thumb moves
## AGAINST the current aim direction, i.e. when the player is turning around.
##
## F1/F2 finding: with a purely trailing anchor, reversing direction meant
## walking the thumb all the way around the anchor — twice the stick radius of
## travel. It read as "aiming just doesn't respond". Holding a direction is
## unaffected, because a stationary thumb has no motion to react to.
## 0 = anchor only trails (the old behaviour), 1 = anchor snaps to the thumb
## the instant you turn.
@export_range(0.0, 1.0, 0.05) var aim_turn_pull: float = 0.35


## The arc threshold curve, in millimetres (SPEC B2). Asymmetric by design.
## Everything is relative to reach_mm, so the shape scales with the player's
## thumb rather than with an abstract coefficient.
func jump_threshold_mm(dx_mm: float) -> float:
	var t: float = clampf(absf(dx_mm) / maxf(reach_mm, 0.1), 0.0, 1.0)
	var delta: float = (rise_left_mm if dx_mm < 0.0 else -drop_right_mm) * t * t
	return maxf(j0_mm + delta, j_min_mm)
