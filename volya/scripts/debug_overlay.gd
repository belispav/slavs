extends CanvasLayer

## VOLYA — control debug overlay (SPEC B5).
## Draws both thumb anchors, the live arc threshold, states and counters,
## and gives three on-device sliders so the feel can be tuned WITHOUT rebuilds.

const FONT_SIZE := 22
const COL_TEXT := Color(0.92, 0.94, 1.0)
const COL_LEFT := Color(0.35, 0.85, 1.0)
const COL_RIGHT := Color(1.0, 0.72, 0.30)
const COL_ARC := Color(0.45, 1.0, 0.55)
const COL_ARC_ARMED := Color(1.0, 0.35, 0.45)
const COL_FAINT := Color(1, 1, 1, 0.12)

var draw_layer: Control
var panel: PanelContainer
var rows: VBoxContainer
var value_labels: Dictionary = {}
var _font: Font


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = ThemeDB.fallback_font

	draw_layer = Control.new()
	draw_layer.name = "DrawLayer"
	draw_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(draw_layer)
	draw_layer.draw.connect(_on_draw)

	_build_panel()


func _process(_delta: float) -> void:
	draw_layer.queue_redraw()
	# Touches that start on the panel must not be read as aiming (SPEC B6 spirit).
	var blockers: Array[Rect2] = []
	if panel != null and panel.visible:
		blockers.append(panel.get_global_rect())
	Touch.ui_blockers = blockers


# ------------------------------------------------------------- panel ------

func _build_panel() -> void:
	panel = PanelContainer.new()
	panel.name = "TunePanel"
	add_child(panel)
	panel.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 12)

	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(300, 0)
	panel.add_child(vb)

	var head := HBoxContainer.new()
	vb.add_child(head)

	var title := Label.new()
	title.text = "LADENIE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)

	var toggle := Button.new()
	toggle.text = "–"
	toggle.custom_minimum_size = Vector2(48, 48)
	head.add_child(toggle)
	toggle.pressed.connect(func() -> void:
		rows.visible = not rows.visible
		toggle.text = "–" if rows.visible else "+"
	)

	rows = VBoxContainer.new()
	vb.add_child(rows)

	_add_slider("J0_MM", 3.0, 20.0, 0.5, Touch.config.j0_mm,
		func(v: float) -> void: Touch.config.j0_mm = v)
	_add_slider("K_ARC", 0.0, 0.05, 0.001, Touch.config.k_arc,
		func(v: float) -> void: Touch.config.k_arc = v)
	_add_slider("HYSTEREZA_MM", 0.5, 8.0, 0.25, Touch.config.hysteresis_mm,
		func(v: float) -> void: Touch.config.hysteresis_mm = v)
	_add_slider("RUN_SAT_MM", 3.0, 30.0, 0.5, Touch.config.run_saturation_mm,
		func(v: float) -> void: Touch.config.run_saturation_mm = v)

	var reset := Button.new()
	reset.text = "RESET POČÍTADLA SKOKOV"
	reset.custom_minimum_size = Vector2(0, 52)
	rows.add_child(reset)
	reset.pressed.connect(func() -> void: Touch.jump_count = 0)


func _add_slider(label_text: String, lo: float, hi: float, step: float,
		start: float, setter: Callable) -> void:
	var row := VBoxContainer.new()
	rows.add_child(row)

	var lbl := Label.new()
	lbl.text = "%s: %s" % [label_text, _fmt(start)]
	row.add_child(lbl)
	value_labels[label_text] = lbl

	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value = start
	s.custom_minimum_size = Vector2(0, 46)
	row.add_child(s)
	s.value_changed.connect(func(v: float) -> void:
		setter.call(v)
		lbl.text = "%s: %s" % [label_text, _fmt(v)]
	)


func _fmt(v: float) -> String:
	if v < 0.1:
		return "%.3f" % v
	return "%.2f" % v


# -------------------------------------------------------------- drawing ---

func _on_draw() -> void:
	var vp: Vector2 = draw_layer.size
	# screen midline — the ownership boundary
	draw_layer.draw_line(Vector2(vp.x * 0.5, 0.0), Vector2(vp.x * 0.5, vp.y), COL_FAINT, 2.0)

	_draw_left(vp)
	_draw_right()
	_draw_hud()


func _draw_left(vp: Vector2) -> void:
	if Touch.left_index == -1:
		return
	var a: Vector2 = Touch.left_anchor
	var p: Vector2 = Touch.left_pos
	var ppm: float = Touch.px_per_mm
	var armed: bool = Touch.is_jump_held()

	# anchor + horizontal run guide
	draw_layer.draw_line(Vector2(0.0, a.y), Vector2(vp.x * 0.5, a.y), COL_FAINT, 1.0)
	draw_layer.draw_circle(a, 10.0, COL_LEFT)
	draw_layer.draw_line(a, p, COL_LEFT, 2.0)
	draw_layer.draw_arc(p, 26.0, 0.0, TAU, 24, COL_LEFT, 3.0)

	# the arc threshold curve  y = anchor.y - J(dx)
	var pts := PackedVector2Array()
	var dx_mm := -45.0
	while dx_mm <= 45.0:
		var j: float = Touch.jump_threshold_mm(dx_mm)
		pts.append(Vector2(a.x + dx_mm * ppm, a.y - j * ppm))
		dx_mm += 1.5
	if pts.size() > 1:
		draw_layer.draw_polyline(pts, COL_ARC_ARMED if armed else COL_ARC, 3.0)

	# the re-arm line (arc minus hysteresis)
	var pts2 := PackedVector2Array()
	dx_mm = -45.0
	while dx_mm <= 45.0:
		var j2: float = Touch.jump_threshold_mm(dx_mm) - Touch.config.hysteresis_mm
		pts2.append(Vector2(a.x + dx_mm * ppm, a.y - j2 * ppm))
		dx_mm += 1.5
	if pts2.size() > 1:
		draw_layer.draw_polyline(pts2, Color(COL_ARC.r, COL_ARC.g, COL_ARC.b, 0.35), 2.0)


func _draw_right() -> void:
	if Touch.right_index == -1:
		return
	var a: Vector2 = Touch.right_anchor
	var p: Vector2 = Touch.right_pos
	draw_layer.draw_arc(a, Touch.config.aim_deadzone_mm * Touch.px_per_mm,
		0.0, TAU, 32, Color(COL_RIGHT.r, COL_RIGHT.g, COL_RIGHT.b, 0.5), 2.0)
	draw_layer.draw_circle(a, 8.0, COL_RIGHT)
	draw_layer.draw_line(a, p, COL_RIGHT, 2.0)
	draw_layer.draw_arc(p, 26.0, 0.0, TAU, 24, COL_RIGHT, 3.0)


func _draw_hud() -> void:
	var state_names := ["NO_TOUCH", "GROUNDED", "JUMP_HELD"]
	var lines := [
		"FPS %d   DPI %d   px/mm %.2f" % [
			Engine.get_frames_per_second(), int(Touch.raw_dpi), Touch.px_per_mm],
		"SKOKY: %d" % Touch.jump_count,
		"stav: %s" % state_names[Touch.left_state],
	]
	if Touch.left_index != -1:
		var dx: float = Touch.left_dx_mm()
		lines.append("dx %.1f mm   hore %.1f mm   prah %.1f mm" % [
			dx, Touch.left_up_mm(), Touch.jump_threshold_mm(dx)])
	else:
		lines.append("ľavý palec: mimo")
	lines.append("mierenie: %s" % ("ZAP" if Touch.aim_active else "vyp"))

	var y := 30.0
	for l in lines:
		draw_layer.draw_string(_font, Vector2(18.0, y), str(l),
			HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, COL_TEXT)
		y += FONT_SIZE + 6.0
