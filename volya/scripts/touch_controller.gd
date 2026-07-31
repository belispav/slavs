extends Node

## VOLYA — "Zero Thumb-Lifting" touch controller (autoload: Touch).
## Implements SPEC_ovladanie_implementacia.md, PART B.
##
## Gameplay code NEVER reads raw touches. It either connects to the signals
## below or polls the public state (move_x, aim_dir, aim_active).

signal move_input(x: float)          # -1..1, emitted every drag/release
signal jump_pressed()                # fires exactly once per armed gesture
signal air_steer(x: float)           # -1..1 while the thumb is in the jump zone
signal aim_input(dir: Vector2, active: bool)

enum LeftState { NO_TOUCH, GROUNDED_INPUT, JUMP_HELD }

const CONFIG_PATH := "res://config/control_config.tres"
const FALLBACK_DPI := 96.0

var config: ControlConfig

# --- public state (poll this from gameplay code) ---
var move_x: float = 0.0
var aim_dir: Vector2 = Vector2.RIGHT
var aim_active: bool = false
var left_state: int = LeftState.NO_TOUCH
## Gestures that crossed the threshold.
var jump_count: int = 0
## Jumps the character actually performed. The gap between the two is the
## number of gestures the game swallowed — the single most useful F1 number.
var jumps_performed: int = 0

# --- left thumb ---
var left_index: int = -1
var left_anchor: Vector2 = Vector2.ZERO
var left_pos: Vector2 = Vector2.ZERO

# --- right thumb ---
var right_index: int = -1
var right_anchor: Vector2 = Vector2.ZERO
var right_pos: Vector2 = Vector2.ZERO
var _right_prev: Vector2 = Vector2.ZERO

# --- screen metrics ---
var px_per_mm: float = 4.0   # in VIEWPORT units, not physical pixels
var raw_dpi: float = FALLBACK_DPI

## Rects (in viewport coordinates) where touches are swallowed by UI,
## e.g. the debug slider panel. Registered by the debug overlay.
var ui_blockers: Array[Rect2] = []

var enabled: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	config = ResourceLoader.load(CONFIG_PATH) as ControlConfig
	if config == null:
		push_warning("control_config.tres not found — using built-in defaults.")
		config = ControlConfig.new()
	_refresh_metrics()
	get_tree().get_root().size_changed.connect(_refresh_metrics)


func _notification(what: int) -> void:
	# Losing focus (call, notification shade, app switch) = all thumbs up.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		reset_all()


## Physical millimetres -> viewport units. The window may be stretched
## (canvas_items mode), so we correct by the window/viewport ratio.
func _refresh_metrics() -> void:
	raw_dpi = float(DisplayServer.screen_get_dpi())
	if raw_dpi <= 1.0:
		raw_dpi = FALLBACK_DPI
	var view_w: float = get_viewport().get_visible_rect().size.x
	var win_w: float = float(DisplayServer.window_get_size().x)
	var stretch: float = 1.0
	if view_w > 0.0 and win_w > 0.0:
		stretch = win_w / view_w
	px_per_mm = maxf((raw_dpi / 25.4) / stretch, 0.5)


func reset_all() -> void:
	left_index = -1
	right_index = -1
	left_state = LeftState.NO_TOUCH
	move_x = 0.0
	aim_active = false
	move_input.emit(0.0)
	aim_input.emit(aim_dir, false)


func jump_threshold_mm(dx_mm: float) -> float:
	return config.jump_threshold_mm(dx_mm)


func is_jump_held() -> bool:
	return left_state == LeftState.JUMP_HELD


## Current upward travel of the left thumb, in mm (negative = below anchor).
func left_up_mm() -> float:
	return (left_anchor.y - left_pos.y) / px_per_mm


## Current sideways offset of the left thumb, in mm.
func left_dx_mm() -> float:
	return (left_pos.x - left_anchor.x) / px_per_mm


# ---------------------------------------------------------------- input ----

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	var touch := event as InputEventScreenTouch
	if touch != null:
		if touch.pressed:
			_on_press(touch.index, touch.position)
		else:
			_on_release(touch.index)
		return
	var drag := event as InputEventScreenDrag
	if drag != null:
		_on_drag(drag.index, drag.position)


func _blocked_by_ui(pos: Vector2) -> bool:
	for r in ui_blockers:
		if r.has_point(pos):
			return true
	return false


func _on_press(index: int, pos: Vector2) -> void:
	if _blocked_by_ui(pos):
		return
	var mid: float = get_viewport().get_visible_rect().size.x * 0.5
	var wants_left: bool = pos.x < mid
	# Ownership is decided by where the touch BEGAN and never changes (SPEC B1).
	if wants_left:
		if left_index == -1:
			_claim_left(index, pos)
		elif right_index == -1:
			_claim_right(index, pos)   # edge case B6: both thumbs on one half
	else:
		if right_index == -1:
			_claim_right(index, pos)
		elif left_index == -1:
			_claim_left(index, pos)


func _claim_left(index: int, pos: Vector2) -> void:
	left_index = index
	left_anchor = pos
	left_pos = pos
	left_state = LeftState.GROUNDED_INPUT
	move_x = 0.0
	move_input.emit(0.0)


func _claim_right(index: int, pos: Vector2) -> void:
	right_index = index
	right_anchor = pos
	right_pos = pos
	_right_prev = pos
	aim_active = false
	aim_input.emit(aim_dir, false)


func _on_release(index: int) -> void:
	if index == left_index:
		left_index = -1
		left_state = LeftState.NO_TOUCH
		move_x = 0.0
		move_input.emit(0.0)
	elif index == right_index:
		right_index = -1
		aim_active = false
		aim_input.emit(aim_dir, false)   # last direction is kept for facing


func _on_drag(index: int, pos: Vector2) -> void:
	if index == left_index:
		left_pos = pos
		_update_left()
	elif index == right_index:
		right_pos = pos
		_update_right()


# ------------------------------------------------- left thumb (SPEC B2) ----

func _update_left() -> void:
	var dx_mm: float = left_dx_mm()
	var up_mm: float = left_up_mm()
	var threshold: float = jump_threshold_mm(dx_mm)

	match left_state:
		LeftState.GROUNDED_INPUT:
			if up_mm > threshold:
				left_state = LeftState.JUMP_HELD
				jump_count += 1
				jump_pressed.emit()
		LeftState.JUMP_HELD:
			# Re-arm only after dragging back below the arc (hysteresis).
			if up_mm < threshold - config.hysteresis_mm:
				left_state = LeftState.GROUNDED_INPUT

	move_x = _run_axis(dx_mm)
	move_input.emit(move_x)
	if left_state == LeftState.JUMP_HELD:
		air_steer.emit(move_x)


func _run_axis(dx_mm: float) -> float:
	var mag: float = absf(dx_mm)
	if mag <= config.run_deadzone_mm:
		return 0.0
	var sat: float = config.run_saturation_left_mm if dx_mm < 0.0 \
		else config.run_saturation_right_mm
	var span: float = maxf(sat - config.run_deadzone_mm, 0.1)
	return signf(dx_mm) * clampf((mag - config.run_deadzone_mm) / span, 0.0, 1.0)


# ------------------------------------------------ right thumb (SPEC B3) ----

func _update_right() -> void:
	var motion: Vector2 = right_pos - _right_prev
	_right_prev = right_pos

	var v: Vector2 = right_pos - right_anchor

	# Turning around: if the thumb moves against the current stick direction,
	# pull the anchor after it instead of making the thumb walk around it.
	# Pushing further out is unaffected, so precision at rest is preserved.
	if config.aim_turn_pull > 0.0 and v.length() > 0.5 and motion.length() > 0.5:
		if motion.normalized().dot(v.normalized()) < 0.0:
			right_anchor = right_anchor.lerp(right_pos, config.aim_turn_pull)
			v = right_pos - right_anchor

	var mm: float = v.length() / px_per_mm

	# Sliding anchor: the stick never runs away from the thumb.
	if mm > config.aim_recenter_mm and mm > 0.0:
		var limit: float = config.aim_recenter_mm * px_per_mm
		right_anchor = right_pos - v.normalized() * limit
		v = right_pos - right_anchor
		mm = config.aim_recenter_mm

	if mm > config.aim_deadzone_mm:
		aim_dir = v.normalized()
		aim_active = true
	else:
		aim_active = false
	aim_input.emit(aim_dir, aim_active)
