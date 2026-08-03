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

	# Godot's default scrollbar is a few pixels wide, which is a mouse
	# measurement. On the phone it cannot be grabbed at all. Widen it to
	# something a thumb can actually land on.
	var bar := scroll.get_v_scroll_bar()
	if bar != null:
		bar.custom_minimum_size = Vector2(48, 0)
		var grabber := StyleBoxFlat.new()
		grabber.bg_color = Color(0.85, 0.87, 0.95, 0.9)
		grabber.set_corner_radius_all(10)
		grabber.content_margin_left = 8.0
		grabber.content_margin_right = 8.0
		var track := StyleBoxFlat.new()
		track.bg_color = Color(1, 1, 1, 0.12)
		track.set_corner_radius_all(10)
		bar.add_theme_stylebox_override("grabber", grabber)
		bar.add_theme_stylebox_override("grabber_highlight", grabber)
		bar.add_theme_stylebox_override("grabber_pressed", grabber)
		bar.add_theme_stylebox_override("scroll", track)

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
	# Samostatne pre kazdy smer - dozadu nie je kam palcom ist.
	_add_slider("BEH_L", 2.0, 30.0, 0.5, Touch.config.run_saturation_left_mm,
		func(v: float) -> void: Touch.config.run_saturation_left_mm = v)
	_add_slider("BEH_P", 2.0, 30.0, 0.5, Touch.config.run_saturation_right_mm,
		func(v: float) -> void: Touch.config.run_saturation_right_mm = v)
	_add_slider("MIER", 3.0, 60.0, 0.5, Touch.config.aim_recenter_mm,
		func(v: float) -> void: Touch.config.aim_recenter_mm = v)
	# 0 = kotva sa len vlecie, 1 = pri otoceni skoci rovno k palcu
	_add_slider("MIER_OTOC", 0.0, 1.0, 0.05, Touch.config.aim_turn_pull,
		func(v: float) -> void: Touch.config.aim_turn_pull = v)
	_add_slider("MIER_MIN", 2.0, 30.0, 0.5, Touch.config.aim_origin_min_mm,
		func(v: float) -> void: Touch.config.aim_origin_min_mm = v)
	_add_slider("ZONA_SIRKA", 0.2, 0.8, 0.01, Touch.config.move_zone_width,
		func(v: float) -> void: Touch.config.move_zone_width = v)
	_add_slider("ZONA_DNO", 0.0, 0.6, 0.01, Touch.config.move_zone_bottom,
		func(v: float) -> void: Touch.config.move_zone_bottom = v)

	# The two aiming schemes sit side by side so they can be compared on the
	# device in one session, which is the only place the answer exists.
	var aim_mode := CheckButton.new()
	aim_mode.text = "MIERIT OD POSTAVY"
	aim_mode.custom_minimum_size = Vector2(0, 56)
	aim_mode.button_pressed = Touch.config.aim_from_character
	rows.add_child(aim_mode)
	aim_mode.toggled.connect(func(on: bool) -> void:
		Touch.config.aim_from_character = on)

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
	var lines: Array[String] = [
		"=== VOLYA ladenie ovladania ===",
		"build                   = %s" % BuildStampScript.STAMP,
		"j0_mm                   = %s" % c.j0_mm,
		"reach_mm                = %s" % c.reach_mm,
		"rise_left_mm            = %s" % c.rise_left_mm,
		"drop_right_mm           = %s" % c.drop_right_mm,
		"j_min_mm                = %s" % c.j_min_mm,
		"hysteresis_mm           = %s" % c.hysteresis_mm,
		"run_deadzone_mm         = %s" % c.run_deadzone_mm,
		"run_saturation_left_mm  = %s" % c.run_saturation_left_mm,
		"run_saturation_right_mm = %s" % c.run_saturation_right_mm,
		"aim_deadzone_mm         = %s" % c.aim_deadzone_mm,
		"aim_recenter_mm         = %s" % c.aim_recenter_mm,
		"aim_turn_pull           = %s" % c.aim_turn_pull,
		"aim_from_character      = %s" % c.aim_from_character,
		"aim_origin_min_mm       = %s" % c.aim_origin_min_mm,
		"move_zone_width         = %s" % c.move_zone_width,
		"move_zone_bottom        = %s" % c.move_zone_bottom,
		"gest / vykonane         = %d / %d" % [Touch.jump_count, Touch.jumps_performed],
		"dpi = %s   px_per_mm = %s" % [Touch.raw_dpi, Touch.px_per_mm],
		"===============================",
	]
	print("")
	for l in lines:
		print(l)
	print("")

	# Zapis aj do suboru, aby sa hodnoty nestratili, ked nebezi logcat.
	# Vytiahnes ich cez tools/get_tuning.ps1
	var f := FileAccess.open("user://tuning.txt", FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(lines) + "\n")
		f.close()
		print("ulozene do user://tuning.txt")
	else:
		push_warning("Nepodarilo sa zapisat user://tuning.txt")


func _fmt(v: float) -> String:
	if absf(v) < 0.1:
		return "%.3f" % v
	return "%.2f" % v


# -------------------------------------------------------------- drawing ---

func _on_draw() -> void:
	var vp: Vector2 = draw_layer.size
	# The boundary is no longer the screen midline but a rectangle, so draw the
	# rectangle. A line here would be describing a rule that no longer applies.
	_draw_move_zone()

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


## Outline of the area where a touch counts as movement. Without it the split
## is invisible and a shot that quietly turned into a step looks like the game
## ignoring the input.
func _draw_move_zone() -> void:
	var zone: Rect2 = Touch.move_zone()
	draw_layer.draw_rect(zone, Color(COL_LEFT.r, COL_LEFT.g, COL_LEFT.b, 0.05),
		true)
	draw_layer.draw_rect(zone, Color(COL_LEFT.r, COL_LEFT.g, COL_LEFT.b, 0.30),
		false, 2.0)


func _draw_right() -> void:
	if Touch.right_index == -1:
		return
	var p: Vector2 = Touch.right_pos

	# Aiming from the character has no anchor and no rings; drawing them would
	# show a stick that is not being used. What matters is the line the shot
	# takes, so draw that instead, continuing past the thumb.
	if Touch.config.aim_from_character:
		if Touch.aim_origin == Vector2.INF:
			return
		var o: Vector2 = Touch.aim_origin
		draw_layer.draw_line(o, p, Color(COL_RIGHT.r, COL_RIGHT.g, COL_RIGHT.b,
			0.45), 2.0)
		draw_layer.draw_line(p, p + Touch.aim_dir * 260.0, COL_RIGHT, 3.0)
		draw_layer.draw_arc(o, Touch.config.aim_origin_min_mm * Touch.px_per_mm,
			0.0, TAU, 32, Color(COL_RIGHT.r, COL_RIGHT.g, COL_RIGHT.b, 0.25), 2.0)
		draw_layer.draw_arc(p, 26.0, 0.0, TAU, 24, COL_RIGHT, 3.0)
		return

	var a: Vector2 = Touch.right_anchor
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
