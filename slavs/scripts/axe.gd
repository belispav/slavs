extends Area2D

## The hero's thrown axe (2026-10-03). One per hero, never freed - it is
## either in the hand (hidden) or in the air.
##
## Flies out along the aim for Tuning.axe_range, then comes back to the hand
## like a boomerang. It hits everything it passes through - once on the way
## out and once more on the way back - so a line of enemies is cut through
## twice. That is the point of the weapon in a mass shooter: no aiming at one
## target, no trading blows with a rusher. The next throw waits for the catch.
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


func _ready() -> void:
	collision_layer = 0
	collision_mask = Tuning.LAYER_TARGET
	var cs := CollisionShape2D.new()
	_circle = CircleShape2D.new()
	_circle.radius = Tuning.AXE_HIT_RADIUS
	cs.shape = _circle
	add_child(cs)

	var tex := load(Tuning.AXE_TEXTURE) as Texture2D
	if tex != null:
		_sprite = Sprite2D.new()
		_sprite.texture = tex
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(_sprite)
	_set_held()


func is_held() -> bool:
	return state == State.HELD


func throw(from: Vector2, direction: Vector2) -> void:
	global_position = from
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

	_hit_overlaps()

	if _sprite != null:
		var s: float = Tuning.player_sprite_scale
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
			for i in Tuning.AXE_DAMAGE:
				landed = victim.call("hit_from", travel)
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
