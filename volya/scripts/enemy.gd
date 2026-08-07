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
## A rusher's swing landing. Not the same moment as touching the player - see
## RUSHER_MELEE_RANGE and _update_attack_timer.
signal melee_hit(from_pos: Vector2)

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
## The range this particular thrower holds. Its own, so a group of them does not
## line up on one arc.
var _keep_distance: float = Tuning.THROWER_KEEP_DISTANCE
var _hurtbox: Area2D
## Drawn character, when one has been rendered. Null means the coloured box,
## which is still a perfectly good enemy and is what every unfinished type uses.
## Points at whichever of the two below matches the current kind - built once
## for both kinds up front, since kind can change every time spawn() reuses
## a pooled node.
var _sprite: AnimatedSprite2D
var _thrower_sprite: AnimatedSprite2D
var _rusher_sprite: AnimatedSprite2D
var _fire_timer: float = 0.0

## RUSHER awareness/attack state - see _think_rusher and _drive_rusher_sprite.
## Sticky once true: an enemy that has noticed the player does not go back to
## looking around, or it would flicker between the two idles at the boundary.
var _aware: bool = false
var _attack_timer: float = 0.0
var _attack_cd: float = 0.0


func _ready() -> void:
	# Lets the debug panel find and despawn enemies by kind without main.gd
	# having to hand out its pool array.
	add_to_group("enemy")
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

	_build_sprite()
	despawn()


## Build the drawn character for the roles that have art.
##
## Both kinds are built here, whether or not their folders are filled yet -
## spawn() picks which one to show. A fresh clone with nothing rendered for
## either gets null back from both and keeps the coloured box, exactly as the
## thrower did on its own before the rusher existed.
func _build_sprite() -> void:
	_thrower_sprite = _build_sprite_from(&"idle", Tuning.THROWER_IDLE_ART_DIR, [
		[&"walk", Tuning.THROWER_WALK_ART_DIR, true],
		# Firing is a one-shot: it must end so the enemy can go back to
		# standing, otherwise it reloads forever and never looks like a shot.
		[&"fire", Tuning.THROWER_FIRE_ART_DIR, false],
	])
	_rusher_sprite = _build_sprite_from(&"idle_unaware", Tuning.RUSHER_IDLE_ART_DIR, [
		[&"idle_ready", Tuning.RUSHER_IDLE_READY_ART_DIR, true],
		[&"walk", Tuning.RUSHER_WALK_ART_DIR, true],
		# One-shot for the same reason as the thrower's fire clip.
		[&"attack", Tuning.RUSHER_ATTACK_ART_DIR, false],
	])
	if _thrower_sprite != null:
		add_child(_thrower_sprite)
	if _rusher_sprite != null:
		add_child(_rusher_sprite)


## One AnimatedSprite2D from a base animation plus any extra clips whose
## folders happen to be filled. base_dir empty means nothing has been
## rendered for this kind yet - returns null, and the caller's coloured box
## fallback takes over, same rule as always.
##
## extra is an Array of [name, art_dir, loop] triples. A triple whose folder
## is empty is skipped rather than failing - partial art (say, only the idle
## rendered so far) still plays, it just cannot show the missing states yet.
func _build_sprite_from(base_anim: StringName, base_dir: String,
		extra: Array) -> AnimatedSprite2D:
	var base_frames := SpriteSequence.load_frames(base_dir)
	if base_frames.is_empty():
		return null

	var sheet := SpriteSequence.build_frames(
		base_frames, String(base_anim), Tuning.ENEMY_ANIM_FPS)
	for item in extra:
		var clip_name: StringName = item[0]
		var dir: String = item[1]
		var loop: bool = item[2]
		var frames := SpriteSequence.load_frames(dir)
		if frames.is_empty():
			continue
		sheet.add_animation(clip_name)
		sheet.set_animation_speed(clip_name, Tuning.ENEMY_ANIM_FPS)
		sheet.set_animation_loop(clip_name, loop)
		for tex in frames:
			sheet.add_frame(clip_name, tex)

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = sheet
	sprite.animation = base_anim
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * Tuning.ENEMY_SPRITE_SCALE
	sprite.z_index = -1

	# Feet on the bottom of the collision box, not on the bottom of the image -
	# the render leaves empty rows below the character from its margin.
	var height: float = float(base_frames[0].get_height())
	var margin: float = float(SpriteSequence.foot_margin(base_frames))
	sprite.position.y = SIZE.y * 0.5 \
		- (height * 0.5 - margin) * Tuning.ENEMY_SPRITE_SCALE
	sprite.visible = false
	sprite.play()
	return sprite


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
	_keep_distance = Tuning.THROWER_KEEP_DISTANCE * randf_range(
		1.0 - Tuning.THROWER_DISTANCE_SPREAD,
		1.0 + Tuning.THROWER_DISTANCE_SPREAD)
	active = true
	_fire_timer = 0.0
	_aware = false
	_attack_timer = 0.0
	_attack_cd = 0.0

	# Each kind shows only its own body. A rusher wearing the gunman's sprite
	# would be a lie the player would learn to read wrongly.
	_sprite = _thrower_sprite if kind == Kind.THROWER else _rusher_sprite
	if _thrower_sprite != null:
		_thrower_sprite.visible = kind == Kind.THROWER
	if _rusher_sprite != null:
		_rusher_sprite.visible = kind == Kind.RUSHER
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


## Whether this enemy's damage comes from a swing (melee_hit) rather than from
## its body touching the player. Read by player.gd's hurtbox handler, which
## otherwise treats any enemy contact as a hit - a rule that stopped being
## true the moment a rusher's attack became a timed swing instead of a shove.
func is_melee_kind() -> bool:
	return kind == Kind.RUSHER


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
				_think_rusher(free, delta)
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
	_drive_sprite(delta)


## Pick the clip from what the enemy is actually doing. Dispatches by kind -
## the thrower's states are speed/firing, the rusher's are awareness/attack.
func _drive_sprite(delta: float) -> void:
	if _sprite == null or not _sprite.visible:
		return

	var wanted: StringName
	match kind:
		Kind.THROWER:
			wanted = _thrower_clip(delta)
		Kind.RUSHER:
			wanted = _rusher_clip()
		_:
			wanted = &"idle"

	var fallback := &"idle_unaware" if kind == Kind.RUSHER else &"idle"
	if not _sprite.sprite_frames.has_animation(wanted):
		wanted = fallback
	if _sprite.animation != wanted:
		_sprite.play(wanted)

	# Sprites are rendered facing left, which is the way enemies travel. Flip
	# only when one is pushed back to the right.
	if absf(velocity.x) > Tuning.ENEMY_WALK_SPEED_MIN:
		_sprite.flip_h = velocity.x > 0.0


## Firing wins while it lasts, then walking or standing by speed. The threshold
## is not zero because holding a distance means constant small corrections, and
## a walk cycle re-triggered every few frames looks like a shiver.
func _thrower_clip(delta: float) -> StringName:
	if _fire_timer > 0.0:
		_fire_timer = maxf(_fire_timer - delta, 0.0)
		return &"fire"
	if velocity.length() > Tuning.ENEMY_WALK_SPEED_MIN:
		return &"walk"
	return &"idle"


## Unaware beats everything - an enemy that has not noticed the player has no
## business swinging or watching. Once aware: attacking, then walking while
## closing, then the ready idle while it holds position between swings.
func _rusher_clip() -> StringName:
	if not _aware:
		return &"idle_unaware"
	if _attack_timer > 0.0:
		return &"attack"
	if velocity.length() > Tuning.ENEMY_WALK_SPEED_MIN:
		return &"walk"
	return &"idle_ready"


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


func _think_rusher(free: bool, delta: float) -> void:
	var speed: float = Tuning.RUSHER_SPEED * Tuning.rusher_speed_scale

	# Notices the player once they are within range on the ground plane.
	# Sticky - see the _aware declaration for why it never turns back off.
	if not _aware and absf(global_position.x - target.global_position.x) \
			<= Tuning.enemy_detection_range:
		_aware = true

	if not _aware:
		# Standing still and looking around, not idling in place mid-stride.
		velocity = velocity.move_toward(Vector2.ZERO, speed * 6.0 * delta)
		_attack_timer = 0.0
		return

	var in_range: bool
	if not free:
		# On a floor there is only one axis to close. The gap is measured from
		# the enemy back to the player, and enemies are always to the right, so
		# it is positive while there is ground to cover.
		var gap: float = global_position.x - target.global_position.x
		in_range = gap <= Tuning.rusher_melee_range
		if not in_range:
			velocity.x = -speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * 6.0)
	else:
		# Head for the player, not for the player's column.
		#
		# Closing X and depth separately made them arrive on the player's
		# vertical line and stop there, still far above or below - lined up
		# rather than converging, and never actually reaching what they came
		# to hit. Moving along the whole vector curves them in.
		var to_target: Vector2 = target.global_position \
			+ Vector2(0.0, _depth_offset + _weave()) - global_position
		var distance: float = to_target.length()
		in_range = distance <= Tuning.rusher_melee_range

		if not in_range:
			var wish: Vector2 = to_target / distance * speed
			# Depth still moves slower than the ground plane, or a body
			# dropping from above outruns one walking in from the right.
			wish.y *= 0.55
			velocity = velocity.move_toward(wish, speed * 6.0 * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, speed * 6.0 * delta)

	_update_attack_timer(in_range, delta)


## Drives the attack/ready-idle cycle once a rusher has closed to melee range,
## and fires the hit itself. The swing lands the moment it triggers, not on
## contact - see the RUSHER_ATTACK_* comment in tuning.gd for the reasoning
## and for what is still a placeholder about the timing.
func _update_attack_timer(in_range: bool, delta: float) -> void:
	if not in_range:
		_attack_cd = Tuning.RUSHER_ATTACK_INTERVAL * 0.5
		_attack_timer = 0.0
		return
	if _attack_timer > 0.0:
		_attack_timer = maxf(_attack_timer - delta, 0.0)
		return
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		_attack_cd = Tuning.RUSHER_ATTACK_INTERVAL
		_attack_timer = Tuning.RUSHER_ATTACK_ANIM_TIME
		melee_hit.emit(global_position)


func _think_thrower(delta: float, free: bool) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = absf(to_target.x)
	var dir: float = signf(to_target.x)
	var speed: float = Tuning.THROWER_SPEED * Tuning.thrower_speed_scale

	# hold the preferred range: close in if far, back off if too close
	if dist > _keep_distance + 60.0:
		velocity.x = dir * speed
	elif dist < _keep_distance - 60.0:
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
		# Show the shot. The clip runs once and then standing takes over,
		# which is what _drive_sprite watches for.
		_fire_timer = Tuning.THROWER_INTERVAL * 0.5


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
	# A drawn character replaces the box entirely. Leaving the box behind the
	# sprite showed as a coloured slab around the legs.
	if _sprite != null and _sprite.visible:
		return
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
