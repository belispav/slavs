extends Node2D

## T31 (Pavel 2026-10-06): a shadow under characters and props.
##
## A flat dark ellipse on the ground, drawn in code (no art). It is a child of
## the thing it belongs to, so it moves and hides with it, but it sits on its
## OWN absolute z: ground shadows lie on the ground, so they must be under
## EVERY character, not sorted by depth like the bodies. A relative z would
## draw the shadow of a character standing in front over the legs of one
## standing behind. The z is Tuning.shadow_z (main.gd sets it from the ground's
## z, a few steps above the ground, its decorations and the blood stains).
##
## Strength and size follow the debug panel live (Tuning.shadow_alpha and
## Tuning.shadow_scale); strength 0 hides it. Later T38 (airborne things fake
## their flight with a ground shadow) can move/size this node from outside.

const POINTS: int = 28
## Outer soft ring and denser core, as fractions of the full ellipse.
const CORE: float = 0.68
## Depth squash: the shadow is this much as tall as it is wide.
const FLATNESS: float = 0.30

var _half_w: float = 20.0
var _alpha_applied: float = -1.0
var _scale_applied: float = -1.0


## `feet_local` = where the thing stands, in the parent's coordinates.
## `width` = full width of the ellipse at scale 1.
func setup(feet_local: Vector2, width: float) -> void:
	position = feet_local
	_half_w = maxf(width, 4.0) * 0.5
	queue_redraw()


## Same, changing only the width (a character that changes kind or scale).
func set_width(width: float) -> void:
	var w: float = maxf(width, 4.0) * 0.5
	if is_equal_approx(w, _half_w):
		return
	_half_w = w
	queue_redraw()


func _ready() -> void:
	z_as_relative = false
	z_index = Tuning.shadow_z
	_refresh()


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	if z_index != Tuning.shadow_z:
		z_index = Tuning.shadow_z
	if not is_equal_approx(_alpha_applied, Tuning.shadow_alpha):
		_alpha_applied = Tuning.shadow_alpha
		modulate.a = _alpha_applied
	if not is_equal_approx(_scale_applied, Tuning.shadow_scale):
		_scale_applied = Tuning.shadow_scale
		scale = Vector2.ONE * _scale_applied


func _draw() -> void:
	_ellipse(1.0, Color(0.0, 0.0, 0.0, 0.5))
	_ellipse(CORE, Color(0.0, 0.0, 0.0, 0.5))


func _ellipse(k: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var rx: float = _half_w * k
	var ry: float = _half_w * FLATNESS * k
	for i in POINTS:
		var a: float = TAU * float(i) / float(POINTS)
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)
