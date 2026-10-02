extends CharacterBody2D

## F1 test dummy player. Grey box, no art — the point is the FEEL, not the look.
## Reads only the TouchController API, never raw touches.

signal fire_requested(from: Vector2, dir: Vector2)
signal health_changed(hp: int)
signal died()

const SIZE := Vector2(30, 54)

var hp: int = Tuning.PLAYER_MAX_HP
var _iframes: float = 0.0
var _hurtbox: Area2D
var _hurt_shape: CollisionShape2D

var aim_dir: Vector2 = Vector2.RIGHT
var facing: int = 1
var spawn_point: Vector2 = Vector2.ZERO

var _fire_cooldown: float = 0.0
var _coyote: float = 0.0
var _jump_buffer: float = 0.0
var _use_keyboard: bool = false
var _kb_jump_was_down: bool = false
var _cam: Camera2D
var _sprite: AnimatedSprite2D          # null when no frames have been rendered yet

## Bounds of the walkable field in free movement, set by the level. Limits
## rather than walls: a solid body ends up drawn over the background.
##
## Held in the body's own coordinates, but set from where the FEET may stand -
## see set_foot_field. Clamping the origin directly was wrong by half a body
## height, which showed up as the character stopping well short of the water
## with a gap under its boots.
var field_top: float = -1e9
var field_bottom: float = 1e9
var field_left: float = -1e9
var field_right: float = 1e9

## Optional per-x top edge, in the same "where the FEET may stand" space
## as the top argument to set_foot_field - set by the level once it has
## read the picture's own silhouette (see Main.walk_top_for_x). Empty
## Callable means "no per-column data": _move_free() then falls back to
## the flat field_top above, so nothing breaks if a level never wires
## this up.
var _foot_top_at: Callable = Callable()

## The bottom-edge mirror of _foot_top_at, same shape, same fallback pattern
## - see Main.walk_bottom_for_x. ADDED 2026-09-15: the top curve existed
## since 2026-09-04 and nobody had mirrored it for the front edge, not on
## purpose - Pavel noticed the top edge already followed the picture and
## asked why the bottom one did not.
var _foot_bottom_at: Callable = Callable()

## How far above the body's origin shots leave from. Derived from the drawing,
## so re-rendering the character at a different height keeps the muzzle on the
## hands instead of drifting to the knees.
var _muzzle_height: float = Tuning.MUZZLE_HEIGHT_FALLBACK
var _has_idle: bool = false
var _rest_frame: int = 0

## True head-to-feet body height, in world units - set once art is loaded,
## 0.0 with no art (the box fallback, where _fit_hurtbox is never called and
## must not be re-driven from here). Kept around so _fit_hurtbox can be
## re-run every frame with the live Tuning.player_hurt_height_fraction,
## instead of being fixed at whatever the fraction was on launch.
var _drawn_height: float = 0.0
## The art's own measurements at 1x, kept so the scale can change live
## (debug panel) without reloading the frames. See _apply_sprite_scale().
var _art_height: float = 0.0
var _art_foot_margin: float = 0.0
var _art_head_margin: float = 0.0
var _applied_scale: float = 0.0


func _ready() -> void:
	add_to_group("player")
	spawn_point = global_position
	collision_layer = Tuning.LAYER_PLAYER
	collision_mask = Tuning.LAYER_WORLD
	floor_snap_length = 8.0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	add_child(shape)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 7.0
	# The platformer looked 60 units up, to see what was above the jump. In free
	# movement the camera is locked and framed deliberately, and that same
	# offset silently eats the band at the bottom where the river is drawn -
	# which is exactly the edge the player reads position from.
	_cam.offset = Vector2.ZERO if Touch.config.free_movement else Vector2(0, -60)
	add_child(_cam)

	# Contact damage from enemy bodies, AND the target enemy bullets look for.
	# collision_layer used to be 0 - detectable by nothing, so this only ever
	# watched for enemies touching it and was never itself a target. Enemy
	# shots hit the player's plain movement CollisionShape2D instead (see
	# _ready below), which is the F1 grey box's size and was never resized
	# to the drawn art - so a shot through the upper body, above that small
	# box, silently missed. LAYER_PLAYER is otherwise unused by anything that
	# would now double-detect it.
	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = Tuning.LAYER_PLAYER
	_hurtbox.collision_mask = Tuning.LAYER_ENEMY
	add_child(_hurtbox)
	_hurt_shape = CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = SIZE * 0.8           # replaced once the drawing is known
	_hurt_shape.shape = hrect
	_hurtbox.add_child(_hurt_shape)
	_hurtbox.body_entered.connect(_on_body_touched)

	_build_sprite()

	_use_keyboard = OS.has_feature("pc")
	Touch.jump_pressed.connect(_on_jump)


## The grey box stays as the fallback. If the art folder is empty - a fresh
## clone, or a render that has not been run yet - the game still starts and
## plays; it just looks like it did during F1.
func _build_sprite() -> void:
	var frames := SpriteSequence.load_frames(Tuning.PLAYER_ART_DIR)
	if frames.is_empty():
		push_warning("Player: ziadne sprajty v %s, kreslim sivy box"
			% Tuning.PLAYER_ART_DIR)
		return

	var sheet := SpriteSequence.build_frames(
		frames, "run", Tuning.PLAYER_ANIM_FPS)

	# A standing animation if one has been rendered; otherwise the run cycle is
	# held on whichever of its frames is closest to upright.
	var idle := SpriteSequence.load_frames(Tuning.PLAYER_IDLE_ART_DIR)
	if idle.is_empty():
		_rest_frame = SpriteSequence.most_upright_frame(frames)
	else:
		_has_idle = true
		sheet.add_animation(&"idle")
		sheet.set_animation_speed(&"idle", Tuning.PLAYER_ANIM_FPS)
		sheet.set_animation_loop(&"idle", true)
		for tex in idle:
			sheet.add_frame(&"idle", tex)

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = sheet
	_sprite.animation = &"run"
	# Nearest, or the whole pixel pass is undone by the GPU smoothing it back.
	# Briefly Linear+mipmaps during the S = 2 pass on 2026-08-13; reverted with
	# it, because Linear is what stopped this being pixel art.
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Behind the node's own _draw(), so the aim line stays visible on top of
	# the body. The aim line is still the main readout for the controls.
	_sprite.z_index = -1

	# Sit the drawing's feet on the bottom of the collision box, not the bottom
	# of the image, which has empty rows above it from the render margin.
	_art_height = float(frames[0].get_height())
	_art_foot_margin = float(SpriteSequence.foot_margin(frames))
	# The true body height, head to feet - NOT canvas height minus the bottom
	# margin, which still counts the empty rows above the head as body. That
	# older "drawn" put the muzzle and the hurtbox both a little too low,
	# the hurtbox enough to miss the top half of the body entirely.
	_art_head_margin = float(SpriteSequence.head_margin(frames))
	_apply_sprite_scale(Tuning.player_sprite_scale)

	add_child(_sprite)
	_sprite.play()


## Size the drawing and everything measured from it: feet on the bottom of
## the collision box, muzzle on the hands, hurtbox on the body. Called once at
## build and again whenever the debug panel flips the scale.
func _apply_sprite_scale(s: float) -> void:
	_applied_scale = s
	_sprite.scale = Vector2.ONE * s
	# Sit the drawing's feet on the bottom of the collision box, not the
	# bottom of the image, which has empty rows below the feet.
	_sprite.position.y = SIZE.y * 0.5 - (_art_height * 0.5 - _art_foot_margin) * s
	var drawn: float = (_art_height - _art_foot_margin - _art_head_margin) * s
	_muzzle_height = drawn * Tuning.MUZZLE_HEIGHT_FRACTION - SIZE.y * 0.5
	_drawn_height = drawn
	_fit_hurtbox(drawn)


## Match the hurt area to the character that is actually drawn.
##
## Sized from the drawing and hung from the feet, so it covers the body from
## about the knees to the top of the head however tall the character is
## rendered. Narrower than the drawing on purpose: arms swing wide, and being
## hit by an elbow is not a hit anyone would accept.
func _fit_hurtbox(drawn_height: float) -> void:
	var rect := _hurt_shape.shape as RectangleShape2D
	if rect == null:
		return
	var tall: float = drawn_height * Tuning.player_hurt_height_fraction
	rect.size = Vector2(Tuning.PLAYER_HURT_WIDTH, tall)
	# Feet are at +SIZE.y/2; hang the box from there so it sits on the body.
	_hurt_shape.position.y = SIZE.y * 0.5 - tall * 0.5 - (drawn_height - tall) * 0.5


## The field, given as where the character's feet may stand.
##
## The level knows the ground in the picture; it has no business knowing how
## tall the collision box is. Converting here keeps that in one place.
func set_foot_field(top: float, bottom: float, left: float, right: float) -> void:
	var feet: float = SIZE.y * 0.5
	field_top = top - feet
	field_bottom = bottom - feet
	field_left = left
	field_right = right


## A top edge that varies with x, read from the level's picture instead
## of one flat number - see the doc comment on _foot_top_at above.
## top_at_x(world_x) must return in the same "where the FEET may stand"
## space set_foot_field's own top argument is in; the feet offset is
## applied here, same as set_foot_field, so the level still never has to
## know how tall the collision box is.
func set_dynamic_top(top_at_x: Callable) -> void:
	_foot_top_at = top_at_x


## The bottom-edge mirror of set_dynamic_top() above.
func set_dynamic_bottom(bottom_at_x: Callable) -> void:
	_foot_bottom_at = bottom_at_x


func set_camera_limits(left: float, right: float, top: float, bottom: float) -> void:
	_cam.limit_left = int(left)
	_cam.limit_right = int(right)
	_cam.limit_top = int(top)
	_cam.limit_bottom = int(bottom)


## Where shots leave from, in world space: roughly the hands.
func muzzle_point() -> Vector2:
	return global_position + Vector2(0.0, -_muzzle_height)


## Back to the start. Only for falling out of the world, where staying put is
## not an option.
func respawn() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
	hp = Tuning.PLAYER_MAX_HP
	_iframes = 0.0
	health_changed.emit(hp)


## Get up where you fell.
##
## Being teleported back to the start on every death made it impossible to
## settle into the game - the run kept restarting before it had begun. Dying
## still costs, but it costs health and a moment of the fight, not the level.
func revive() -> void:
	hp = Tuning.PLAYER_MAX_HP
	_iframes = Tuning.PLAYER_REVIVE_IFRAMES
	velocity = Vector2.ZERO
	health_changed.emit(hp)


func _on_body_touched(body: Node) -> void:
	# A melee kind's damage comes from its swing landing (enemy.gd's
	# melee_hit, wired in main.gd), not from its body touching this one - a
	# rusher standing at its own weapon's reach is not touching the player at
	# all. Anything that is not a melee kind (nothing is, yet) still hits on
	# plain contact.
	if body.has_method("is_melee_kind") and body.is_melee_kind():
		return
	take_damage(Tuning.ENEMY_CONTACT_DAMAGE, Vector2.ZERO)


## Called by enemy bodies on contact and by enemy projectiles.
func take_damage(amount: int, from_pos: Vector2) -> void:
	if Debug.god_mode:
		return
	if _iframes > 0.0 or hp <= 0:
		return
	hp -= amount
	_iframes = Tuning.PLAYER_IFRAMES
	var away: float = 1.0
	if from_pos != Vector2.ZERO:
		away = signf(global_position.x - from_pos.x)
		if is_zero_approx(away):
			away = 1.0
	velocity.x = away * Tuning.PLAYER_KNOCKBACK.x
	velocity.y = Tuning.PLAYER_KNOCKBACK.y
	health_changed.emit(hp)
	if hp <= 0:
		died.emit()


## A jump gesture never fails outright — it is buffered and fires as soon as
## the character can actually jump.
func _on_jump() -> void:
	_jump_buffer = Tuning.JUMP_BUFFER


func _consume_jump_buffer(delta: float) -> void:
	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	if _jump_buffer <= 0.0:
		return
	if is_on_floor() or _coyote > 0.0:
		velocity.y = Tuning.JUMP_VELOCITY
		_coyote = 0.0
		_jump_buffer = 0.0
		Touch.jumps_performed += 1


func _physics_process(delta: float) -> void:
	if Touch.config.free_movement:
		_move_free(delta)
	else:
		_move_platform(delta)

	_iframes = maxf(_iframes - delta, 0.0)
	move_and_slide()
	# Depth is Y, same rule as the enemies - the player is not special, and an
	# enemy standing nearer the camera should cover him.
	z_index = Tuning.depth_z(global_position.y)

	# Cheap enough to redo every frame, and it is what makes the hurtbox
	# fraction slider in the debug panel actually live instead of only
	# taking effect after the next redeploy.
	if _sprite != null and Tuning.player_sprite_scale != _applied_scale:
		_apply_sprite_scale(Tuning.player_sprite_scale)
	if _drawn_height > 0.0:
		_fit_hurtbox(_drawn_height)

	# Aim from the hands, not from the middle of the collision box. Both the
	# shot and the direction start at the same point, or the line drawn on
	# screen would not be the line the bullets take.
	Touch.aim_origin = get_viewport().get_canvas_transform() * muzzle_point()

	_update_aim(delta)
	_update_sprite()
	queue_redraw()


## Run and jump along a floor. The F1 behaviour.
func _move_platform(delta: float) -> void:
	var ix: float = _move_axis()

	var accel: float = Tuning.AIR_ACCEL
	if is_on_floor():
		accel = Tuning.GROUND_DECEL if is_zero_approx(ix) else Tuning.GROUND_ACCEL
	velocity.x = move_toward(velocity.x,
		ix * Tuning.RUN_SPEED * Tuning.player_speed_scale, accel * delta)

	if is_on_floor():
		_coyote = Tuning.COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y = minf(velocity.y + Tuning.GRAVITY * delta, Tuning.MAX_FALL_SPEED)

	_consume_jump_buffer(delta)


## Walk the field on both axes. No gravity, no jump, no floor.
##
## Vertical travel is deliberately slower than horizontal: the depth axis is
## for dodging, not for crossing ground, and a field that moves as fast
## vertically as horizontally reads as floating rather than walking.
func _move_free(delta: float) -> void:
	if Touch.config.free_move_follow and not _use_keyboard:
		# The character copies the thumb: travel becomes velocity for this one
		# frame, so it stops the instant the thumb does even while still held.
		# Capped, or a fast flick would fling the character across the level.
		var travel: Vector2 = Touch.consume_travel() * Touch.config.free_move_gain
		travel.y *= Touch.config.free_move_y_ratio
		velocity = (travel / maxf(delta, 0.0001)).limit_length(
			Tuning.RUN_SPEED * 2.0)
	else:
		var wish: Vector2 = _move_vector()
		wish.y *= Touch.config.free_move_y_ratio

		var accel: float = Tuning.GROUND_DECEL if wish.is_zero_approx() \
			else Tuning.GROUND_ACCEL
		var goal: Vector2 = wish * Tuning.RUN_SPEED * Tuning.player_speed_scale
		velocity.x = move_toward(velocity.x, goal.x, accel * delta)
		velocity.y = move_toward(velocity.y, goal.y, accel * delta)

	_coyote = 0.0
	_jump_buffer = 0.0

	# Applied after the velocity, before move_and_slide, so pressing against
	# an edge simply stops rather than juddering. There are no walls in free
	# movement - a solid body would be drawn over the background - so every
	# edge of the field is a limit like this one.
	var next: Vector2 = global_position + velocity * delta
	# The rock edge the level measured from the picture, if any - see
	# _foot_top_at above. Sampled at the column the character is moving
	# INTO, so the bound is already correct for a column change made this
	# frame, not one frame late.
	var top_bound: float = field_top
	if _foot_top_at.is_valid():
		top_bound = float(_foot_top_at.call(next.x)) - SIZE.y * 0.5
	# The front edge, same idea, mirrored - see _foot_bottom_at above.
	var bottom_bound: float = field_bottom
	if _foot_bottom_at.is_valid():
		bottom_bound = float(_foot_bottom_at.call(next.x)) - SIZE.y * 0.5
	# Pull both edges in by the same amount, live-tunable - see
	# Tuning.walk_edge_inset. Added 2026-09-15: with the top edge now
	# following the true silhouette (see _foot_top_at), the character could
	# walk its feet right onto the measured line, which read as standing IN
	# the grass rather than at its edge. minf/maxf guard against an inset
	# large enough to invert the two bounds (top below bottom) on a field
	# this narrow.
	top_bound = minf(top_bound + Tuning.walk_edge_inset, field_bottom)
	bottom_bound = maxf(bottom_bound - Tuning.walk_edge_inset, top_bound)
	if next.y < top_bound or next.y > bottom_bound:
		global_position.y = clampf(global_position.y, top_bound, bottom_bound)
		velocity.y = 0.0
	if next.x < field_left or next.x > field_right:
		global_position.x = clampf(global_position.x, field_left, field_right)
		velocity.x = 0.0


# ---------------------------------------------------------------- input ---

func _move_axis() -> float:
	if _use_keyboard:
		var kx: float = 0.0
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			kx -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			kx += 1.0
		var jump_down: bool = Input.is_physical_key_pressed(KEY_SPACE) \
			or Input.is_physical_key_pressed(KEY_W)
		if jump_down and not _kb_jump_was_down:
			_on_jump()
		_kb_jump_was_down = jump_down
		if not is_zero_approx(kx):
			return kx
	return Touch.move_x


## Both axes, for free movement. On a keyboard W and S drive depth instead of
## jumping, since there is nothing to jump over.
func _move_vector() -> Vector2:
	if _use_keyboard:
		var kv := Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			kv.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			kv.x += 1.0
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			kv.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			kv.y += 1.0
		if kv != Vector2.ZERO:
			return kv.normalized()
	return Touch.move_vec


func _keyboard_aim() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_J):
		v.x -= 1.0
	if Input.is_physical_key_pressed(KEY_L):
		v.x += 1.0
	if Input.is_physical_key_pressed(KEY_I):
		v.y -= 1.0
	if Input.is_physical_key_pressed(KEY_K):
		v.y += 1.0
	return v


func _update_aim(delta: float) -> void:
	var active: bool = Touch.aim_active
	var dir: Vector2 = Touch.aim_dir

	if _use_keyboard:
		var kv: Vector2 = _keyboard_aim()
		if kv != Vector2.ZERO:
			dir = kv.normalized()
			active = true

	if active:
		aim_dir = dir
		if absf(aim_dir.x) > 0.2:
			facing = 1 if aim_dir.x > 0.0 else -1
	elif absf(velocity.x) > 10.0:
		facing = 1 if velocity.x > 0.0 else -1

	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	if active and _fire_cooldown <= 0.0:
		_fire_cooldown = Tuning.FIRE_INTERVAL
		fire_requested.emit(
			muzzle_point() + aim_dir * Tuning.MUZZLE_DISTANCE, aim_dir)


# --------------------------------------------------------------- visuals ---

func _update_sprite() -> void:
	if _sprite == null:
		return

	_sprite.flip_h = (facing > 0) if Tuning.PLAYER_ART_FACES_LEFT else (facing < 0)

	# Speed is taken from both axes: in free movement, walking straight up the
	# field is still walking and should not freeze the sprite.
	var speed: float = velocity.length() if Touch.config.free_movement \
		else absf(velocity.x)
	var moving: bool = speed > Tuning.PLAYER_ANIM_MIN_SPEED

	if moving:
		if _sprite.animation != &"run":
			_sprite.animation = &"run"
		if not _sprite.is_playing():
			_sprite.play()
	elif _has_idle:
		if _sprite.animation != &"idle":
			_sprite.animation = &"idle"
			_sprite.play()
	elif _sprite.is_playing():
		# No standing animation rendered yet, so hold the least wrong frame of
		# the run rather than frame zero - which is mid-stride, on one leg and
		# leaning forward.
		_sprite.stop()
		_sprite.frame = _rest_frame

	var tint := Color.WHITE
	if _iframes > 0.0:
		tint = tint.lerp(Color(1.0, 0.4, 0.4), 0.5 + 0.5 * sin(_iframes * 45.0))
	_sprite.modulate = tint


func _draw() -> void:
	if _sprite == null:
		# Fallback for a project with no rendered art yet.
		var body := Color(0.78, 0.80, 0.85)
		if _iframes > 0.0:
			body = body.lerp(Color(1.0, 0.4, 0.4),
				0.5 + 0.5 * sin(_iframes * 45.0))
		draw_rect(Rect2(-SIZE * 0.5, SIZE), body)
		draw_rect(Rect2(Vector2(float(facing) * 6.0 - 4.0, -SIZE.y * 0.5 + 8.0),
			Vector2(8, 8)), Color(0.15, 0.16, 0.2))

	# Drawn from the muzzle, not from the body's origin. Left at the origin it
	# sat by the character's feet while the shots came from the chest, which
	# made the aim look wrong at exactly the moment it had been fixed.
	var muzzle := Vector2(0.0, -_muzzle_height)
	draw_line(muzzle, muzzle + aim_dir * Tuning.MUZZLE_DISTANCE,
		Color(1.0, 0.85, 0.35), 5.0)
