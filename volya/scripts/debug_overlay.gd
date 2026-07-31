extends CanvasLayer

## VOLYA — control debug overlay (SPEC B5).
## Draws both thumb anchors, the live arc threshold, states and counters,
## and gives three on-device sliders so the feel can be tuned WITHOUT rebuilds.

const FONT_SIZE := 22
const PANEL_W := 330.0
const PANEL_MARGIN := 16.0

## preload namiesto class_name — nezavisi na globalnej cache tried,
## takze headless export na tom nepadne.
const BuildStampScript := preload("res://scripts/build_stamp.gd")
const COL_TEXT := Color(0.92, 0.94, 1.0)
const COL_LEFT := Color(0.35, 0.85, 1.0)
const COL_RIGHT := Color(1.0, 0.72, 0.30)
const COL_ARC := Color(0.45, 1.0, 0.55)
const COL_ARC_ARMED := Color(1.0, 0.35, 0.45)
const COL_FAINT := Color(1, 1, 1, 0.12)

var draw_layer: Control
var panel: PanelContainer
var scroll: ScrollContainer
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
	# Grow LEFT and DOWN, so the panel can never run off the right edge.
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_END
	add_child(panel)

	var vb := VBoxContainer.new()
	panel.add_child(vb)

	var head := HBoxContainer.new()
	vb.add_child(head)

	var title := Label.new()
	title.text = "LADENIE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)

	var toggle := Button.new()
	toggle.text = "-"
	toggle.custom_minimum_size = Vector2(56, 56)
	head.add_child(toggle)
	toggle.pressed.connect(func() -> void:
		scroll.visible = not scroll.visible
		toggle.text = "-" if scroll.visible else "+"
	)

	# Posuvniky su v scrollovacom okne, aby panel nikdy nepretiekol mimo displej,
	# ani ked ich pribudne.
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)

	rows = VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)

	# Kratke nazvy, aby sa panel zmestil na displej telefonu.
	_add_slider("PRAH", 3.0, 20.0, 0.5, Touch.config.j0_mm,
		func(v: float) -> void: Touch.config.j0_mm = v)
	# Vsetko v milimetroch, vztiahnute na skutocny rozsah palca.
	_add_slider("ROZSAH", 5.0, 35.0, 0.5, Touch.config.reach_mm,
		func(v: float) -> void: Touch.config.reach_mm = v)
	_add_slider("VLAVO+", 0.0, 20.0, 0.25, Touch.config.rise_left_mm,
		func(v: float) -> void: Touch.config.rise_left_mm = v)
	_add_slider("VPRAVO-", 0.0, 20.0, 0.25, Touch.config.drop_right_mm,
		func(v: float) -> void: Touch.config.drop_right_mm = v)
	_add_slider("DNO", 0.0, 10.0, 0.25, Touch.config.j_min_mm,
		func(v: float) -> void: Touch.config.j_min_mm = v)
	_add_slider("REARM", 0.0, 8.0, 0.25, Touch.config.hysteresis_mm,
		func(v: float) -> void: Touch.config.hysteresis_mm = v)
	_add_slider("BEH", 3.0, 30.0, 0.5, Touch.config.run_saturation_mm,
		func(v: float) -> void: Touch.config.run_saturation_mm = v)
	_add_slider("MIER", 3.0, 60.0, 0.5, Touch.config.aim_recenter_mm,
		func(v: float) -> void: Touch.config.aim_recenter_mm = v)

	var buttons := HBoxContainer.new()
	vb.add_child(buttons)

	var dump := Button.new()
	dump.text = "VYPIS DO LOGU"
	dump.custom_minimum_size = Vector2(0, 52)
	dump.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(dump)
	dump.pressed.connect(_dump_values)

	var reset := Button.new()
	reset.text = "RESET"
	reset.custom_minimum_size = Vector2(0, 52)
	buttons.add_child(reset)
	reset.pressed.connect(func() -> void:
		Touch.jump_count = 0
		Touch.jumps_performed = 0
	)

	_layout_panel()
	get_viewport().size_changed.connect(_layout_panel)


## Explicitne ukotvenie vpravo hore, s odsadenim podla bezpecnej zony displeja
## (vyrez kamery, zaoblene rohy). Preset s MINSIZE tu nefungoval, lebo sa
## pocital skor, nez panel poznal svoju sirku.
func _layout_panel() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var right_inset: float = 0.0
	var top_inset: float = 0.0

	var win: Vector2i = DisplayServer.window_get_size()
	if win.x > 0 and view.x > 0.0:
		var s: float = view.x / float(win.x)
		var safe: Rect2i = DisplayServer.get_display_safe_area()
		if safe.size.x > 0:
			right_inset = maxf(float(win.x - (safe.position.x + safe.size.x)) * s, 0.0)
			top_inset = maxf(float(safe.position.y) * s, 0.0)

	# Vyska scrollovacieho okna: co zostane pod hlavickou, nikdy nie viac.
	scroll.custom_minimum_size = Vector2(0, maxf(view.y * 0.62, 120.0))

	var w: float = minf(PANEL_W, view.x * 0.45)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_right = -(PANEL_MARGIN + right_inset)
	panel.offset_left = panel.offset_right - w
	panel.offset_top = PANEL_MARGIN + top_inset
	panel.offset_bottom = panel.offset_top


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
	s.custom_minimum_size = Vector2(0, 40)
	row.add_child(s)
	s.value_changed.connect(func(v: float) -> void:
		setter.call(v)
		lbl.text = "%s: %s" % [label_text, _fmt(v)]
	)


## Vypise vsetky aktualne hodnoty do logu, aby sa nemuseli opisovat z displeja.
## V termináli ich vidis v zivom logcate a mozes ich rovno skopirovat.
func _dump_values() -> void:
	var c: ControlConfig = Touch.config
	print("")
	print("=== VOLYA ladenie ovladania ===")
	print("build            = ", BuildStampScript.STAMP)
	print("j0_mm            = ", c.j0_mm)
	print("reach_mm         = ", c.reach_mm)
	print("rise_left_mm     = ", c.rise_left_mm)
	print("drop_right_mm    = ", c.drop_right_mm)
	print("j_min_mm         = ", c.j_min_mm)
	print("hysteresis_mm    = ", c.hysteresis_mm)
	print("run_deadzone_mm  = ", c.run_deadzone_mm)
	print("run_saturation_mm= ", c.run_saturation_mm)
	print("aim_deadzone_mm  = ", c.aim_deadzone_mm)
	print("aim_recenter_mm  = ", c.aim_recenter_mm)
	print("gest / vykonane  = ", Touch.jump_count, " / ", Touch.jumps_performed)
	print("dpi = ", Touch.raw_dpi, "  px_per_mm = ", Touch.px_per_mm)
	print("===============================")
	print("")


func _fmt(v: float) -> String:
	if absf(v) < 0.1:
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
	# outer ring = point where the anchor starts sliding after the thumb
	draw_layer.draw_arc(a, Touch.config.aim_recenter_mm * Touch.px_per_mm,
		0.0, TAU, 48, Color(COL_RIGHT.r, COL_RIGHT.g, COL_RIGHT.b, 0.22), 2.0)
	draw_layer.draw_circle(a, 8.0, COL_RIGHT)
	draw_layer.draw_line(a, p, COL_RIGHT, 2.0)
	draw_layer.draw_arc(p, 26.0, 0.0, TAU, 24, COL_RIGHT, 3.0)


func _draw_hud() -> void:
	var state_names := ["NO_TOUCH", "GROUNDED", "JUMP_HELD"]
	var lines := [
		"BUILD: %s" % BuildStampScript.STAMP,
		"FPS %d   DPI %d   px/mm %.2f" % [
			Engine.get_frames_per_second(), int(Touch.raw_dpi), Touch.px_per_mm],
		"SKOKY: gesto %d / vykonane %d  (prehltnute %d)" % [
			Touch.jump_count, Touch.jumps_performed,
			maxi(Touch.jump_count - Touch.jumps_performed, 0)],
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
