extends Area2D

## The hero's thrown axe (2026-10-03). One per hero, never freed - it is
## either in the hand (hidden) or in the air.
##
## Flies out along the aim for Tuning.axe_range, then comes back to the hand.
## It hits everything it passes through on the way OUT (and pushes it); on the
## way back (Pavel 2026-10-07) it is half transparent, harmless and faster -
## unless Tuning.AXE_RETURN_HURTS (a future boomerang upgrade), and even then it
## never pushes. That is the point of the weapon in a mass shooter: no aiming
## at one target, no trading blows with a rusher. The next throw waits for the
## catch.
##
## Hits go through the same layer and the same hit() method as the player's
## bullets, so anything a bullet can hit, the axe can hit too (enemies, the
## barrel, the F1 dummy targets).

signal caught()

enum State { HELD, OUT, BACK }

var state: int = State.HELD
var thrower: Node2D                     # the player; set by main.gd

var _dir: Vector2 = Vector2.RIGHT
var _travelled: float = 0.0
var _back_time: float = 0.0
## Everything hit on the CURRENT leg. Cleared when the axe turns round, so
## each victim can be hit once out and once back.
var _hit_this_leg: Array = []
var _sprite: Sprite2D
var _circle: CircleShape2D
## Ground shadow (T31): the axe flies at hand height, so its shadow hangs this
## far below it, measured at the throw (hero's feet minus the throw point).
var _shadow: Node2D
const ShadowScript := preload("res://scripts/shadow.gd")
var _zone_drawn: bool = false


## Debug (panel UKAZ ZONY ZASAHU): the circle the axe tests against enemies'
## hurt rectangles. Red = it hurts now (way out), grey = harmless (way back).
func _draw() -> void:
	if not Debug.show_hit_zones:
		return
	var live: bool = state == State.OUT or Tuning.AXE_RETURN_HURTS
	var col := Color(1.0, 0.15, 0.1) if live else Color(0.6, 0.6, 0.6)
	draw_circle(Vector2.ZERO, _circle.radius, Color(col, 0.25))
	draw_arc(Vector2.ZERO, _circle.radius, 0.0, TAU, 40, Color(col, 0.95), 2.0)


func _ready() -> void:
	collision_layer = 0
	collision_mask = Tuning.LAYER_TARGET
	var cs := CollisionShape2D.new()
	_circle = CircleShape2D.new()
	_circle.radius = Tuning.axe_hit_radius
	cs.shape = _circle
	add_child(cs)

	var tex := load(Tuning.AXE_TEXTURE) as Texture2D
	if tex != null:
		_sprite = Sprite2D.new()
		_sprite.texture = tex
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(_sprite)
	_shadow = ShadowScript.new()
	add_child(_shadow)
	_shadow.setup(Vector2.ZERO, 36.0)
	_set_held()


func is_held() -> bool:
	return state == State.HELD


func throw(from: Vector2, direction: Vector2) -> void:
	global_position = from
	var drop: float = 40.0
	if thrower != null:
		drop = clampf(thrower.global_position.y + thrower.SIZE.y * 0.5 - from.y, 0.0, 240.0)
	_shadow.position = Vector2(0.0, drop)
	_dir = direction.normalized() if direction != Vector2.ZERO else Vector2.RIGHT
	_travelled = 0.0
	_back_time = 0.0
	_hit_this_leg.clear()
	state = State.OUT
	show()
	set_physics_process(true)
	set_deferred("monitoring", true)


## Back in the hand at once - used when the field is cleared (death,
## restart). It MUST still emit caught: on 2026-10-03 it did not, so dying
## with the axe in the air left the hero empty-handed for good (the axe was
## home, but the hero was never told).
func recall() -> void:
	var was_out: bool = state != State.HELD
	_set_held()
	if was_out:
		caught.emit()


func _set_held() -> void:
	state = State.HELD
	hide()
	set_physics_process(false)
	set_deferred("monitoring", false)


func _physics_process(delta: float) -> void:
	if state == State.OUT:
		var step: float = Tuning.axe_speed * delta
		global_position += _dir * step
		_travelled += step
		if _travelled >= Tuning.axe_range:
			state = State.BACK
			_hit_this_leg.clear()
	elif state == State.BACK:
		_back_time += delta
		var target: Vector2 = _catch_point()
		var to_hand: Vector2 = target - global_position
		var step_back: float = Tuning.axe_speed * Tuning.AXE_RETURN_FACTOR * delta
		# Caught when it reaches the hand - or, as a safety net, after a
		# fixed time, so a hero who keeps running away is never left
		# without a weapon.
		if to_hand.length() <= maxf(step_back, Tuning.AXE_CATCH_RADIUS) \
				or _back_time > Tuning.AXE_MAX_RETURN_TIME:
			_set_held()
			caught.emit()
			return
		global_position += to_hand.normalized() * step_back

	if not is_equal_approx(_circle.radius, Tuning.axe_hit_radius):
		_circle.radius = Tuning.axe_hit_radius
	if state == State.OUT or Tuning.AXE_RETURN_HURTS:
		_hit_overlaps()
	if Debug.show_hit_zones or _zone_drawn:
		_zone_drawn = Debug.show_hit_zones
		queue_redraw()

	if _sprite != null:
		var s: float = Tuning.player_sprite_scale
		_sprite.modulate.a = Tuning.AXE_RETURN_ALPHA if state == State.BACK else 1.0
		_sprite.scale = Vector2.ONE * s
		_sprite.rotation += Tuning.AXE_SPIN * delta * (1.0 if _dir.x >= 0.0 else -1.0)
	z_index = Tuning.depth_z(global_position.y) + 1


func _catch_point() -> Vector2:
	if thrower != null and thrower.has_method("muzzle_point"):
		return thrower.muzzle_point()
	return global_position


## Polled every frame rather than driven by area_entered: a victim the axe is
## still inside when it turns round must be hit again on the way back, and
## area_entered would never fire a second time for it.
func _hit_overlaps() -> void:
	for area in get_overlapping_areas():
		var victim: Node = area
		if not victim.has_method("hit") and area.get_parent() != null:
			victim = area.get_parent()
		if not victim.has_method("hit"):
			continue
		if _hit_this_leg.has(victim):
			continue
		_hit_this_leg.append(victim)
		# Armour (the brute's front plate) is decided by the direction the
		# axe is travelling, not by where it was thrown from - an axe that
		# flew past and comes back hits him from behind.
		if victim.has_method("hit_from"):
			var travel: Vector2 = _dir
			if state == State.BACK:
				travel = (_catch_point() - global_position).normalized()
			var landed: bool = false
			# T33: only the way out pushes (a returning axe never does).
			var push_dist: float = Tuning.axe_push if state == State.OUT else 0.0
			for i in Tuning.AXE_DAMAGE:
				landed = victim.call("hit_from", travel, push_dist)
				if not landed:
					break
			if not landed and state == State.OUT:
				# Bounced off the plate: turn round now. The victim stays on
				# this leg's list, so it is not struck again on the spot.
				state = State.BACK
				_hit_this_leg.clear()
				_hit_this_leg.append(victim)
			continue
		for i in Tuning.AXE_DAMAGE:
			victim.call("hit")
