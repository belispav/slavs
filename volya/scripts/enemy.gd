extends CharacterBody2D

## Pooled enemy. Two behaviours for now (plan 3.5 wants 8 types eventually):
##   RUSHER  - closes distance and hurts on contact
##   THROWER - keeps its distance and throws spears
##
## Enemies die in 1-3 hits and are generous to the player, per design pillar 1.
## Defined by ROLE and EQUIPMENT only, never by origin or appearance
## (CLAUDE.md hard content rule).

signal died(at: Vector2)
signal throw_requested(from: Vector2, dir: Vector2)

enum Kind { RUSHER, THROWER }

const SIZE := Vector2(30, 52)

var kind: int = Kind.RUSHER
var hp: int = 2
var active: bool = false
var target: Node2D

var _flash: float = 0.0
var _throw_cd: float = 0.0
var _hurtbox: Area2D


func _ready() -> void:
	collision_layer = Tuning.LAYER_ENEMY
	collision_mask = Tuning.LAYER_WORLD
	floor_snap_length = 8.0

	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	cs.shape = rect
	add_child(cs)

	# Bullets look for LAYER_TARGET, so the enemy carries a hurtbox on it.
	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = Tuning.LAYER_TARGET
	_hurtbox.collision_mask = 0
	_hurtbox.monitoring = false
	_hurtbox.monitorable = true
	add_child(_hurtbox)
	var hs := CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = SIZE * 1.15          # generous hitbox, favours the player
	hs.shape = hrect
	_hurtbox.add_child(hs)

	despawn()


func spawn(pos: Vector2, new_kind: int, player: Node2D) -> void:
	global_position = pos
	kind = new_kind
	target = player
	hp = Tuning.RUSHER_HP if kind == Kind.RUSHER else Tuning.THROWER_HP
	velocity = Vector2.ZERO
	_flash = 0.0
	_throw_cd = randf() * Tuning.THROWER_INTERVAL
	active = true
	show()
	set_physics_process(true)
	set_deferred("monitorable", true)
	_hurtbox.set_deferred("monitorable", true)
	queue_redraw()


func despawn() -> void:
	active = false
	hide()
	set_physics_process(false)
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", false)


## Called by the player's bullets (via the hurtbox).
func hit() -> void:
	if not active:
		return
	hp -= 1
	_flash = 1.0
	if hp <= 0:
		died.emit(global_position)
		despawn()


func _physics_process(delta: float) -> void:
	var free: bool = Touch.config.free_movement

	if free:
		# No floor to stand on, so no gravity. Depth is just another axis.
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y = minf(velocity.y + Tuning.ENEMY_GRAVITY * delta, 1800.0)
	else:
		velocity.y = 0.0

	if target != null:
		match kind:
			Kind.RUSHER:
				_think_rusher(free)
			Kind.THROWER:
				_think_thrower(delta, free)

	move_and_slide()
	_stay_right_of_player()
	# Redraw ONLY while the hit flash is fading. Moving a Node2D does not need
	# a redraw, and 34 pointless redraws per frame cost real frame time on a
	# phone — which shows up as the controls feeling sticky.
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 6.0, 0.0)
		queue_redraw()


## Hard floor on how far left an enemy may be. Applied after moving, so nothing
## can slip past through a collision push or a fast frame.
##
## Sliding along this line rather than being stopped by it is deliberate: an
## enemy that reaches the player keeps its vertical movement, so a crowd
## presses in and spreads out instead of stacking into one point.
func _stay_right_of_player() -> void:
	if target == null:
		return
	var limit: float = target.global_position.x + Tuning.ENEMY_KEEP_RIGHT_MARGIN
	if global_position.x < limit:
		global_position.x = limit
		velocity.x = maxf(velocity.x, 0.0)


func _think_rusher(free: bool) -> void:
	var to_target: Vector2 = target.global_position - global_position

	# Close in from the right and stop short. Pressing against the player is
	# the attack; there is nothing to gain from running past.
	if to_target.x < Tuning.ENEMY_STOP_GAP:
		velocity.x = move_toward(velocity.x, 0.0, Tuning.RUSHER_SPEED * 6.0)
	else:
		velocity.x = -Tuning.RUSHER_SPEED

	if free:
		velocity.y = signf(to_target.y) * Tuning.RUSHER_SPEED * 0.6 \
			if absf(to_target.y) > 8.0 else 0.0


func _think_thrower(delta: float, free: bool) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = absf(to_target.x)
	var dir: float = signf(to_target.x)

	# hold the preferred range: close in if far, back off if too close
	if dist > Tuning.THROWER_KEEP_DISTANCE + 60.0:
		velocity.x = dir * Tuning.THROWER_SPEED
	elif dist < Tuning.THROWER_KEEP_DISTANCE - 60.0:
		velocity.x = -dir * Tuning.THROWER_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, Tuning.THROWER_SPEED * 4.0 * delta)

	if free:
		velocity.y = signf(to_target.y) * Tuning.THROWER_SPEED * 0.5 \
			if absf(to_target.y) > 24.0 else 0.0

	_throw_cd -= delta
	if _throw_cd <= 0.0 and dist < Tuning.THROWER_RANGE:
		_throw_cd = Tuning.THROWER_INTERVAL
		var aim: Vector2 = (target.global_position - global_position).normalized()
		throw_requested.emit(global_position + aim * 30.0, aim)


func _draw() -> void:
	var base := Color(0.62, 0.30, 0.28) if kind == Kind.RUSHER else Color(0.40, 0.34, 0.52)
	var col := base.lerp(Color(1.0, 0.96, 0.92), _flash)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), col)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), Color(0.10, 0.11, 0.14), false, 3.0)
	# equipment marker, so the two roles read apart at a glance
	if kind == Kind.RUSHER:
		draw_rect(Rect2(Vector2(-4, -SIZE.y * 0.5 - 10), Vector2(8, 10)),
			Color(0.85, 0.85, 0.9))
	else:
		draw_line(Vector2(-16, -14), Vector2(16, -22), Color(0.85, 0.85, 0.9), 4.0)
