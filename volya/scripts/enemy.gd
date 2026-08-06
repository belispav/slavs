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
## Each enemy aims for its own depth slightly off the player's, so a crowd
## surrounds rather than forming a single line.
var _depth_offset: float = 0.0
var _weave_time: float = 0.0
var _weave_rate: float = 1.0
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
	_depth_offset = randf_range(-Tuning.ENEMY_DEPTH_SPREAD,
		Tuning.ENEMY_DEPTH_SPREAD)
	_weave_time = randf() * TAU
	_weave_rate = Tuning.ENEMY_WEAVE_SPEED * randf_range(0.6, 1.4)
	active = true
	show()
	set_physics_process(true)
	set_deferred("collision_layer", Tuning.LAYER_ENEMY)
	set_deferred("monitorable", true)
	_hurtbox.set_deferred("monitorable", true)
	queue_redraw()


func despawn() -> void:
	active = false
	hide()
	set_physics_process(false)
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", false)
	# The body itself has to leave the enemy layer too, not just stop moving and
	# stop being drawn. Without this a killed enemy leaves its collider standing
	# where it fell, and walking over that spot costs a life to something
	# invisible that is not there.
	set_deferred("collision_layer", 0)


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
		# No floor to stand on, so no gravity. Depth is just another axis, and
		# the vertical speed is left alone here - zeroing it every frame would
		# undo the easing that stops enemies snapping onto the player's line.
		pass
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
	_keep_out_of_the_left()
	# Redraw ONLY while the hit flash is fading. Moving a Node2D does not need
	# a redraw, and 34 pointless redraws per frame cost real frame time on a
	# phone — which shows up as the controls feeling sticky.
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 6.0, 0.0)
		queue_redraw()


## Enemies do not walk left past the player, and the ones the player leaves
## behind are recycled.
##
## The first version pinned them to the player's x. That does hold the rule, but
## it drags: run to the right and every enemy is carried along at the player's
## speed, pinned to the same column, which looks like teleporting and is exactly
## what it is. An enemy overtaken by the player is chaff that has served its
## purpose - it goes back to the pool and the spawner sends another from the
## right, where they belong.
func _keep_out_of_the_left() -> void:
	if target == null:
		return
	if global_position.x < target.global_position.x - Tuning.ENEMY_CULL_BEHIND:
		despawn()
		return
	# Their own leftward movement still stops at the player. Nothing is moved
	# here, only prevented.
	var limit: float = target.global_position.x + Tuning.ENEMY_KEEP_RIGHT_MARGIN
	if global_position.x < limit and velocity.x < 0.0:
		velocity.x = 0.0


func _think_rusher(free: bool) -> void:
	var speed: float = Tuning.RUSHER_SPEED * Tuning.rusher_speed_scale

	if not free:
		# On a floor there is only one axis to close. The gap is measured from
		# the enemy back to the player, and enemies are always to the right, so
		# it is positive while there is ground to cover.
		var gap: float = global_position.x - target.global_position.x
		if gap > Tuning.ENEMY_STOP_GAP:
			velocity.x = -speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * 6.0)
		return

	# Head for the player, not for the player's column.
	#
	# Closing X and depth separately made them arrive on the player's vertical
	# line and stop there, still far above or below - lined up rather than
	# converging, and never actually reaching what they came to hit. Moving
	# along the whole vector curves them in.
	var to_target: Vector2 = target.global_position \
		+ Vector2(0.0, _depth_offset + _weave()) - global_position
	var distance: float = to_target.length()

	if distance > Tuning.ENEMY_STOP_GAP:
		var wish: Vector2 = to_target / distance * speed
		# Depth still moves slower than the ground plane, or a body dropping
		# from above outruns one walking in from the right.
		wish.y *= 0.55
		velocity = velocity.move_toward(wish,
			speed * 6.0 * get_physics_process_delta_time())
	else:
		velocity = velocity.move_toward(Vector2.ZERO,
			speed * 6.0 * get_physics_process_delta_time())


func _think_thrower(delta: float, free: bool) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = absf(to_target.x)
	var dir: float = signf(to_target.x)
	var speed: float = Tuning.THROWER_SPEED * Tuning.thrower_speed_scale

	# hold the preferred range: close in if far, back off if too close
	if dist > Tuning.THROWER_KEEP_DISTANCE + 60.0:
		velocity.x = dir * speed
	elif dist < Tuning.THROWER_KEEP_DISTANCE - 60.0:
		velocity.x = -dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 4.0 * delta)

	if free:
		_track_depth(speed * 0.8)

	_throw_cd -= delta
	if _throw_cd <= 0.0 and dist < Tuning.THROWER_RANGE:
		_throw_cd = Tuning.THROWER_INTERVAL
		var aim: Vector2 = (target.global_position - global_position).normalized()
		throw_requested.emit(global_position + aim * 30.0, aim)


## A sideways drift across the approach, so the path curves instead of being a
## ruled line. Each enemy has its own phase and rate, so a crowd does not weave
## in unison - which would look even more mechanical than a straight line.
func _weave() -> float:
	_weave_time += get_physics_process_delta_time() * _weave_rate
	return sin(_weave_time) * Tuning.ENEMY_WEAVE_AMPLITUDE


## Close on the player's depth, but smoothly and never exactly.
##
## Setting the vertical speed outright made a crowd snap onto the player's line
## and stay glued there, which read as teleporting rather than walking. Easing
## into the speed gives it weight, and the per-enemy offset stops thirty bodies
## from converging into one row.
func _track_depth(speed: float) -> void:
	var wanted: float = target.global_position.y + _depth_offset - global_position.y
	var goal: float = 0.0
	if absf(wanted) > 6.0:
		goal = clampf(wanted / 40.0, -1.0, 1.0) * speed
	velocity.y = move_toward(velocity.y, goal,
		speed * 4.0 * get_physics_process_delta_time())


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
