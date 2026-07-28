extends CharacterBody2D

## F1 test dummy player. Grey box, no art — the point is the FEEL, not the look.
## Reads only the TouchController API, never raw touches.

signal fire_requested(from: Vector2, dir: Vector2)

const SIZE := Vector2(30, 54)

var aim_dir: Vector2 = Vector2.RIGHT
var facing: int = 1
var spawn_point: Vector2 = Vector2.ZERO

var _fire_cooldown: float = 0.0
var _coyote: float = 0.0
var _use_keyboard: bool = false
var _kb_jump_was_down: bool = false
var _cam: Camera2D


func _ready() -> void:
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
	_cam.offset = Vector2(0, -60)
	add_child(_cam)

	_use_keyboard = OS.has_feature("pc")
	Touch.jump_pressed.connect(_on_jump)


func set_camera_limits(left: float, right: float, top: float, bottom: float) -> void:
	_cam.limit_left = int(left)
	_cam.limit_right = int(right)
	_cam.limit_top = int(top)
	_cam.limit_bottom = int(bottom)


func respawn() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO


func _on_jump() -> void:
	_try_jump()


func _try_jump() -> void:
	if is_on_floor() or _coyote > 0.0:
		velocity.y = Tuning.JUMP_VELOCITY
		_coyote = 0.0


func _physics_process(delta: float) -> void:
	var ix: float = _move_axis()

	var accel: float = Tuning.AIR_ACCEL
	if is_on_floor():
		accel = Tuning.GROUND_DECEL if is_zero_approx(ix) else Tuning.GROUND_ACCEL
	velocity.x = move_toward(velocity.x, ix * Tuning.RUN_SPEED, accel * delta)

	if is_on_floor():
		_coyote = Tuning.COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y = minf(velocity.y + Tuning.GRAVITY * delta, Tuning.MAX_FALL_SPEED)

	move_and_slide()
	_update_aim(delta)
	queue_redraw()


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
			_try_jump()
		_kb_jump_was_down = jump_down
		if not is_zero_approx(kx):
			return kx
	return Touch.move_x


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
			global_position + aim_dir * Tuning.MUZZLE_DISTANCE, aim_dir)


# --------------------------------------------------------------- visuals ---

func _draw() -> void:
	draw_rect(Rect2(-SIZE * 0.5, SIZE), Color(0.78, 0.80, 0.85))
	# facing marker
	draw_rect(Rect2(Vector2(float(facing) * 6.0 - 4.0, -SIZE.y * 0.5 + 8.0),
		Vector2(8, 8)), Color(0.15, 0.16, 0.2))
	# gun barrel
	draw_line(Vector2.ZERO, aim_dir * Tuning.MUZZLE_DISTANCE,
		Color(1.0, 0.85, 0.35), 5.0)
