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
## 0 = anchor only trails, 1 = anchor snaps to the thumb the instant you turn.
##
## DEFAULT 0 — TRIED ON DEVICE AND REJECTED. Pulling the anchor toward the
## thumb shrinks the stick offset below aim_deadzone_mm, so aim_active drops
## and AUTO-FIRE STOPS exactly during a turn, which is the worst possible
## moment in a horde shooter.
##
## Do not simply raise this value again. The turn cost is real, but the fix has
## to separate FIRING from AIM MAGNITUDE — e.g. latch auto-fire on while the
## right thumb is down and let the offset only decide direction. Left here so
## the idea and the reason it failed are not lost.
@export_range(0.0, 1.0, 0.05) var aim_turn_pull: float = 0.0

## Where the aim direction is measured FROM.
##
## false — from an anchor created under the thumb. The lever is only
##         aim_recenter_mm long, so a millimetre of thumb tremor is a large
##         change of angle. This is the F1 behaviour.
## true  — from the character itself. The thumb points a direction rather than
##         holding a stick: the shot travels from the character through the
##         thumb and onward, so a distant enemy needs no reach and is never
##         hidden under the thumb. The lever becomes the whole distance from
##         character to thumb, typically 30-60 mm instead of 12, which is the
##         same tremor spread over three to five times less angle.
##
## Added because aiming read as uncontrollably twitchy on device and the cause
## was the short lever, not the player's thumb.
@export var aim_from_character: bool = false

## Below this distance between the character and the thumb, the direction is
## held rather than recomputed. Close in, the angle between them swings wildly
## for almost no thumb movement, which is the same twitchiness in a smaller
## place. Firing continues; only the direction stops updating.
@export_range(2.0, 30.0, 0.5) var aim_origin_min_mm: float = 9.0

## The movement pad, as fractions of the screen. A touch that starts inside it
## drives movement; everything else aims.
##
## It is not simply the left half any more. Aiming turned out to be far more
## comfortable with the right INDEX finger than with the thumb, and an index
## finger reaches the bottom left corner easily - where the touch was being
## taken as movement, so the shot never happened. Standing still and shooting
## down-left was impossible.
##
## The bottom band is excluded because that is where the character stands: a
## thumb resting there covers the thing the player is trying to watch. Resting
## it around mid height also puts it below the jump flick rather than at the
## bottom of the travel.
@export_range(0.2, 0.8, 0.01) var move_zone_width: float = 0.5
@export_range(0.0, 0.6, 0.01) var move_zone_bottom: float = 0.28

## Free movement: the left thumb drives both axes and there is no gravity and
## no jump. The character walks around the field instead of running along a
## floor, the way a beat-em-up does.
##
## Worth trying because the jump is the most complicated thing in the project -
## six of the ten sliders exist to serve it - and the design already calls for
## levels with no gravity at all. If free movement is the better game, that
## whole subsystem stops being needed.
##
## Enemies still come only from the right either way. That is not about the
## genre, it is about the hand: the left thumb physically covers the left third
## of the screen, so a threat arriving from there cannot be seen.
@export var free_movement: bool = false

## Vertical travel in free movement, as a fraction of the horizontal speed.
## Below 1.0 the field feels wider than it is tall, which is how the genre
## usually plays - the depth axis is for dodging, not for crossing ground.
@export_range(0.2, 1.0, 0.05) var free_move_y_ratio: float = 0.62


## The arc threshold curve, in millimetres (SPEC B2). Asymmetric by design.
## Everything is relative to reach_mm, so the shape scales with the player's
## thumb rather than with an abstract coefficient.
func jump_threshold_mm(dx_mm: float) -> float:
	var t: float = clampf(absf(dx_mm) / maxf(reach_mm, 0.1), 0.0, 1.0)
	var delta: float = (rise_left_mm if dx_mm < 0.0 else -drop_right_mm) * t * t
	return maxf(j0_mm + delta, j_min_mm)
