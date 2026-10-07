extends Node2D

## Hit and death effects (2026-10-03) - blood, wood splinters, dust/smoke.
##
## Drawn in code as square pixels, not as PixelLab art: Pavel wanted to try
## the MECHANIC first ("presny efekt nie je az tak podstatny"), and code
## particles cost no generations and every number is live. The final look can
## replace them with PixelLab clips later without touching the call sites.
##
## The field is 2.5D, so every particle has a spot on the GROUND (x, y) and a
## HEIGHT above it (h). It is drawn at (x, y - h). Blood and splinters fly up,
## fall back to h = 0 and stay there as a stain where they landed - in front
## of or behind a body according to their own ground y - then fade. Smoke
## (rises and grows) is kept in the code but no longer used: Pavel found the
## death cloud odd and the square smoke wrong for a barrel (2026-10-03).
##
## Two layers, because a stain on the ground must be covered by whoever walks
## over it while a particle in the air must not be: `_ground` sits just above
## the background, this node (the air) above everything.
##
## One node per layer draws every particle with draw_rect - one draw call per
## layer, no nodes per particle, so a crowd dying at once stays cheap
## (performance target: 60 fps on a ~150 EUR phone).

enum Type { BLOOD, WOOD, SMOKE }

const MAX_PARTICLES: int = 700
const GRAVITY: float = 900.0

# Per particle, parallel arrays (no per-particle objects to allocate).
var _pos: PackedVector2Array = PackedVector2Array()   # ground spot
var _vel: PackedVector2Array = PackedVector2Array()   # ground velocity
var _h: PackedFloat32Array = PackedFloat32Array()     # height above ground
var _vh: PackedFloat32Array = PackedFloat32Array()    # vertical speed (+ = up)
var _age: PackedFloat32Array = PackedFloat32Array()
var _life: PackedFloat32Array = PackedFloat32Array()
var _size: PackedFloat32Array = PackedFloat32Array()
var _type: PackedInt32Array = PackedInt32Array()
var _col: PackedColorArray = PackedColorArray()
var _landed: PackedByteArray = PackedByteArray()

var _ground: Node2D

## A5/A6 floating damage numbers (parallel arrays like the particles).
const NUMBER_LIFE: float = 0.7
const NUMBER_RISE: float = 50.0
const MAX_NUMBERS: int = 40
var _tx_pos: PackedVector2Array = PackedVector2Array()
var _tx_age: PackedFloat32Array = PackedFloat32Array()
var _tx_crit: PackedByteArray = PackedByteArray()
var _tx_text: PackedStringArray = PackedStringArray()

const BLOOD_COLOURS: Array[Color] = [
	Color(0.80, 0.06, 0.06), Color(0.95, 0.16, 0.12), Color(0.60, 0.03, 0.05)]
const WOOD_COLOURS: Array[Color] = [
	Color(0.86, 0.66, 0.38), Color(0.95, 0.80, 0.52), Color(0.62, 0.42, 0.22)]
const FIRE_COLOURS: Array[Color] = [
	Color(1.0, 0.85, 0.3), Color(1.0, 0.55, 0.1), Color(0.95, 0.3, 0.05),
	Color(1.0, 0.95, 0.7)]
const DARK_SMOKE_COLOURS: Array[Color] = [
	Color(0.25, 0.23, 0.22), Color(0.35, 0.33, 0.3), Color(0.18, 0.17, 0.16)]
const SCORCH_COLOURS: Array[Color] = [
	Color(0.15, 0.13, 0.12), Color(0.3, 0.2, 0.15), Color(0.6, 0.25, 0.08)]
const SPARK_COLOURS: Array[Color] = [
	Color(1.0, 0.95, 0.6), Color(1.0, 0.8, 0.3), Color(1.0, 1.0, 0.9)]
const SMOKE_COLOURS: Array[Color] = [
	Color(0.85, 0.83, 0.78), Color(0.72, 0.70, 0.66), Color(0.95, 0.93, 0.88)]


func setup(ground_z: int) -> void:
	z_index = 4090
	_ground = Node2D.new()
	_ground.z_as_relative = false
	_ground.z_index = ground_z + 1
	_ground.draw.connect(_draw_ground)
	# The ground layer is a sibling-like child but must not inherit our high z.
	add_child(_ground)


## A body was hit (`fatal` = it died). `feet` is where it stands, `height` its
## drawn height in world units, `away` +1/-1 the side the blow came FROM the
## opposite of, so blood sprays away from the hero.
## `count` > 0 overrides how many drops (the hero's own hits use it).
func body_hit(feet: Vector2, height: float, away: float, fatal: bool, count: int = 0) -> void:
	if not Tuning.fx_enabled:
		return
	var at_h: float = height * 0.55
	var n: int = Tuning.FX_BLOOD_DEATH if fatal else Tuning.FX_BLOOD_HIT
	if count > 0:
		n = count
	for i in n:
		var speed: float = randf_range(60.0, 260.0) if fatal else randf_range(40.0, 160.0)
		var vx: float = away * speed * randf_range(0.3, 1.0) + randf_range(-40.0, 40.0)
		var vy: float = randf_range(-70.0, 70.0)
		_spawn(Type.BLOOD, feet + Vector2(randf_range(-6, 6), randf_range(-3, 3)),
			Vector2(vx, vy), at_h + randf_range(-12, 12), randf_range(80.0, 300.0),
			Tuning.fx_stain_time, 4.0 if randf() < 0.6 else 6.0,
			BLOOD_COLOURS[randi() % BLOOD_COLOURS.size()])


## A barrel was hit; `broken` = it burst.
func wood_hit(feet: Vector2, away: float, broken: bool) -> void:
	if not Tuning.fx_enabled:
		return
	var n: int = Tuning.FX_WOOD_BREAK if broken else Tuning.FX_WOOD_HIT
	for i in n:
		var speed: float = randf_range(80.0, 320.0) if broken else randf_range(40.0, 140.0)
		var dir: float = away if not broken else (1.0 if randf() < 0.5 else -1.0)
		_spawn(Type.WOOD, feet + Vector2(randf_range(-14, 14), randf_range(-4, 4)),
			Vector2(dir * speed * randf_range(0.3, 1.0), randf_range(-90.0, 90.0)),
			randf_range(20.0, 56.0), randf_range(120.0, 360.0),
			Tuning.fx_stain_time, 4.0 if randf() < 0.6 else 6.0,
			WOOD_COLOURS[randi() % WOOD_COLOURS.size()])


## A cauldron going off: a burst of fire that rises and fades, dark smoke
## above it, and burnt debris that lands as a scorch around the spot.
func explosion(feet: Vector2) -> void:
	if not Tuning.fx_enabled:
		return
	for i in 46:
		var a: float = randf() * TAU
		var sp: float = randf_range(60.0, 260.0)
		_spawn(Type.SMOKE, feet + Vector2(randf_range(-20, 20), randf_range(-6, 6)),
			Vector2(cos(a) * sp, sin(a) * sp * 0.35),
			randf_range(10.0, 70.0), randf_range(40.0, 160.0),
			randf_range(0.25, 0.55), randf_range(8.0, 16.0),
			FIRE_COLOURS[randi() % FIRE_COLOURS.size()])
	for i in 18:
		_spawn(Type.SMOKE, feet + Vector2(randf_range(-30, 30), randf_range(-6, 6)),
			Vector2(randf_range(-40.0, 40.0), randf_range(-10.0, 10.0)),
			randf_range(40.0, 100.0), randf_range(30.0, 80.0),
			randf_range(0.8, 1.4), randf_range(12.0, 20.0),
			DARK_SMOKE_COLOURS[randi() % DARK_SMOKE_COLOURS.size()])
	for i in 34:
		var a2: float = randf() * TAU
		var sp2: float = randf_range(100.0, 420.0)
		_spawn(Type.WOOD, feet,
			Vector2(cos(a2) * sp2, sin(a2) * sp2 * 0.4),
			randf_range(20.0, 60.0), randf_range(120.0, 380.0),
			Tuning.fx_stain_time, 4.0 if randf() < 0.6 else 6.0,
			SCORCH_COLOURS[randi() % SCORCH_COLOURS.size()])


## Steel on steel - the axe glancing off armour. `at` is the spot in the air
## (not the feet); short-lived bright bits that bounce back toward the hero.
func sparks(at: Vector2, away: float) -> void:
	if not Tuning.fx_enabled:
		return
	for i in 10:
		_spawn(Type.SMOKE, at + Vector2(0.0, 60.0), Vector2(
			-away * randf_range(60.0, 240.0), randf_range(-60.0, 60.0)),
			60.0 + randf_range(-10.0, 10.0), randf_range(-60.0, 160.0),
			randf_range(0.12, 0.3), 4.0,
			SPARK_COLOURS[randi() % SPARK_COLOURS.size()])


func _puff(feet: Vector2, n: int, spread: float) -> void:
	for i in n:
		_spawn(Type.SMOKE, feet + Vector2(randf_range(-spread, spread), randf_range(-4, 4)),
			Vector2(randf_range(-30.0, 30.0), randf_range(-8.0, 8.0)),
			randf_range(4.0, 40.0), randf_range(20.0, 60.0),
			randf_range(0.5, 0.9), randf_range(8.0, 14.0),
			SMOKE_COLOURS[randi() % SMOKE_COLOURS.size()])


func _spawn(t: int, ground: Vector2, vel: Vector2, h: float, vh: float,
		life: float, size: float, col: Color) -> void:
	if _pos.size() >= MAX_PARTICLES:
		_remove(0)  # oldest first - a full screen of stains must not stop new hits
	_pos.append(ground)
	_vel.append(vel)
	_h.append(h)
	_vh.append(vh)
	_age.append(0.0)
	_life.append(life)
	_size.append(size)
	_type.append(t)
	_col.append(col)
	_landed.append(0)


## A number that floats up from `at` (just above the victim's head) and fades.
## A critical hit is bigger and yellow.
func damage_number(at: Vector2, amount: int, crit: bool) -> void:
	if _tx_text.size() >= MAX_NUMBERS:
		_remove_number(0)
	_tx_pos.append(at + Vector2(randf_range(-10.0, 10.0), 0.0))
	_tx_age.append(0.0)
	_tx_crit.append(1 if crit else 0)
	_tx_text.append(("KRIT %d!" % amount) if crit else str(amount))


func _remove_number(i: int) -> void:
	_tx_pos.remove_at(i); _tx_age.remove_at(i); _tx_crit.remove_at(i); _tx_text.remove_at(i)


func _remove(i: int) -> void:
	_pos.remove_at(i); _vel.remove_at(i); _h.remove_at(i); _vh.remove_at(i)
	_age.remove_at(i); _life.remove_at(i); _size.remove_at(i); _type.remove_at(i)
	_col.remove_at(i); _landed.remove_at(i)


## Wipe everything - used when the field is reset after a death.
func clear() -> void:
	while _pos.size() > 0:
		_remove(_pos.size() - 1)
	while _tx_text.size() > 0:
		_remove_number(_tx_text.size() - 1)
	queue_redraw()
	_ground.queue_redraw()


func _process(delta: float) -> void:
	# Numbers redraw while any exist, plus once more when the last one is gone.
	var had_numbers: bool = not _tx_text.is_empty()
	var n: int = _tx_text.size() - 1
	while n >= 0:
		_tx_age[n] += delta
		_tx_pos[n] += Vector2(0.0, -NUMBER_RISE * delta)
		if _tx_age[n] >= NUMBER_LIFE:
			_remove_number(n)
		n -= 1
	if _pos.is_empty():
		if had_numbers:
			queue_redraw()
		return
	var i: int = _pos.size() - 1
	while i >= 0:
		_age[i] += delta
		if _type[i] == Type.SMOKE:
			_pos[i] += _vel[i] * delta
			_h[i] += _vh[i] * delta
			_size[i] += delta * 24.0
			if _age[i] >= _life[i]:
				_remove(i)
		elif _landed[i] == 0:
			_pos[i] += _vel[i] * delta
			_vh[i] -= GRAVITY * delta
			_h[i] += _vh[i] * delta
			if _h[i] <= 0.0:
				_h[i] = 0.0
				_landed[i] = 1
				_age[i] = 0.0   # the stain's own clock starts on landing
		elif _age[i] >= _life[i]:
			_remove(i)
		i -= 1
	queue_redraw()
	_ground.queue_redraw()


## Air layer: everything not yet landed.
func _draw() -> void:
	for i in _pos.size():
		if _landed[i] == 1:
			continue
		var a: float = 1.0
		if _type[i] == Type.SMOKE:
			a = 0.9 * (1.0 - _age[i] / _life[i])
		_draw_px(self, i, a)
	_draw_numbers()


func _draw_numbers() -> void:
	var font: Font = ThemeDB.fallback_font
	for i in _tx_text.size():
		var crit: bool = _tx_crit[i] == 1
		var fade: float = clampf((1.0 - _tx_age[i] / NUMBER_LIFE) * 2.5, 0.0, 1.0)
		var size: int = int(Tuning.damage_number_size * (1.4 if crit else 1.0))
		var p: Vector2 = Vector2(floorf(_tx_pos[i].x * 0.5) * 2.0 - 60.0,
			floorf(_tx_pos[i].y * 0.5) * 2.0)
		var col: Color = Color(1.0, 0.85, 0.15, fade) if crit else Color(1.0, 1.0, 1.0, fade)
		draw_string_outline(font, p, _tx_text[i], HORIZONTAL_ALIGNMENT_CENTER, 120.0,
			size, 6, Color(0.0, 0.0, 0.0, fade))
		draw_string(font, p, _tx_text[i], HORIZONTAL_ALIGNMENT_CENTER, 120.0, size, col)


## Ground layer: stains, fading over the last third of their life.
func _draw_ground() -> void:
	for i in _pos.size():
		if _landed[i] == 0:
			continue
		var left: float = 1.0 - _age[i] / _life[i]
		_draw_px(_ground, i, clampf(left * 3.0, 0.0, 1.0))


## Snapped to the 2-unit grid every sprite is drawn on (integer 2x), so the
## particles read as the same pixels as the characters, never half a pixel.
func _draw_px(canvas: CanvasItem, i: int, alpha: float) -> void:
	var s: float = floorf(_size[i] * 0.5) * 2.0
	var p: Vector2 = _pos[i] - Vector2(0.0, _h[i])
	p = Vector2(floorf(p.x * 0.5) * 2.0, floorf(p.y * 0.5) * 2.0)
	var c: Color = _col[i]
	c.a = alpha
	# Landed blood and splinters spread flat - wider than tall, it lies on
	# the ground.
	var r := Rect2(p - Vector2(s, s) * 0.5, Vector2(s, s))
	if _landed[i] == 1:
		var flat := Vector2(s + 2.0, maxf(2.0, s * 0.5))
		r = Rect2(p - flat * 0.5, flat)
	canvas.draw_rect(r, c)
