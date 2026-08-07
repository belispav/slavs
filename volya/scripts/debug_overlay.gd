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
var _title: Label
var _toggle: Button


## Show or hide every tuning readout at once.
##
## Anything in the "debug_ui" group goes with it, which is how the scoreboard in
## main.gd disappears too - the overlay has no business knowing that node exists.
func _set_debug_visible(on: bool) -> void:
	scroll.visible = on
	if _title != null:
		_title.visible = on
	if _toggle != null:
		_toggle.text = "-" if on else "+"
	if draw_layer != null:
		draw_layer.visible = on
	if panel != null:
		# Transparent when collapsed, so only the small button remains.
		panel.self_modulate.a = 1.0 if on else 0.0
	for node in get_tree().get_nodes_in_group("debug_ui"):
		node.visible = on
	# The area the panel blocks from gameplay touches is recomputed every frame
	# in _process from its own rectangle, which shrinks with it. Nothing to do
	# here - and calling something that does not exist would take the whole
	# script down with it.


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

	_title = title
	var toggle := Button.new()
	toggle.text = "-"
	toggle.custom_minimum_size = Vector2(56, 56)
	head.add_child(toggle)
	_toggle = toggle
	toggle.pressed.connect(func() -> void:
		# Everything, not just the sliders. The touch circles, the vectors, the
		# movement rectangle and the counters are all readouts for tuning, and
		# while they are on there is no way to see the game itself.
		_set_debug_visible(not scroll.visible)
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

	# Only the sliders that do something in the current mode are built. Fourteen
	# sliders, most of them inert, is enough to lose the one that matters - and
	# a slider that does nothing is worse than no slider, because moving it and
	# feeling no change reads as the game being broken.
	var c: ControlConfig = Touch.config

	# Testing switches, not tuning. They never touch control_config.tres and
	# must never ship - see debug_state.gd. Kept at the top of the panel since
	# they are the ones reached for mid-crowd, not while sitting still tuning
	# a slider.
	_add_note("TEST")
	var god_mode := CheckButton.new()
	god_mode.text = "NESMRTELNOST"
	god_mode.custom_minimum_size = Vector2(0, 56)
	god_mode.button_pressed = Debug.god_mode
	rows.add_child(god_mode)
	god_mode.toggled.connect(func(on: bool) -> void:
		Debug.god_mode = on)

	var pause_mode := CheckButton.new()
	pause_mode.text = "PAUZA"
	pause_mode.custom_minimum_size = Vector2(0, 56)
	pause_mode.button_pressed = get_tree().paused
	rows.add_child(pause_mode)
	pause_mode.toggled.connect(func(on: bool) -> void:
		# The panel's own CanvasLayer is PROCESS_MODE_ALWAYS (see _ready), and
		# every row here is its child, so the sliders and buttons keep working
		# while the rest of the tree - player, enemies, spawner - freezes.
		get_tree().paused = on)

	var no_rusher := CheckButton.new()
	no_rusher.text = "VYPNUT BEZCOV"
	no_rusher.custom_minimum_size = Vector2(0, 56)
	no_rusher.button_pressed = Debug.disable_rusher
	rows.add_child(no_rusher)
	no_rusher.toggled.connect(func(on: bool) -> void:
		Debug.disable_rusher = on
		if on:
			_despawn_kind(0))

	var no_thrower := CheckButton.new()
	no_thrower.text = "VYPNUT STRELCOV"
	no_thrower.custom_minimum_size = Vector2(0, 56)
	no_thrower.button_pressed = Debug.disable_thrower
	rows.add_child(no_thrower)
	no_thrower.toggled.connect(func(on: bool) -> void:
		Debug.disable_thrower = on
		if on:
			_despawn_kind(1))

	if c.free_movement:
		_add_note("POHYB")
		if c.free_move_follow:
			_add_slider("o kolko dalej ide postava nez palec", 1.0, 8.0, 0.25,
				c.free_move_gain,
				func(v: float) -> void: Touch.config.free_move_gain = v)
		else:
			_add_slider("posun palca pre plnu rychlost vlavo", 2.0, 30.0, 0.5,
				c.run_saturation_left_mm,
				func(v: float) -> void: Touch.config.run_saturation_left_mm = v)
			_add_slider("posun palca pre plnu rychlost vpravo", 2.0, 30.0, 0.5,
				c.run_saturation_right_mm,
				func(v: float) -> void: Touch.config.run_saturation_right_mm = v)
		_add_slider("o kolko pomalsi je pohyb hore-dole", 0.2, 1.0, 0.05,
			c.free_move_y_ratio,
			func(v: float) -> void: Touch.config.free_move_y_ratio = v)
	else:
		_add_note("SKOK")
		_add_slider("ako prudko svihnut na skok", 3.0, 20.0, 0.5, c.j0_mm,
			func(v: float) -> void: Touch.config.j0_mm = v)
		_add_slider("dosah tvojho palca", 5.0, 35.0, 0.5, c.reach_mm,
			func(v: float) -> void: Touch.config.reach_mm = v)
		_add_slider("nesumernost dovnutra", 0.0, 20.0, 0.25, c.rise_left_mm,
			func(v: float) -> void: Touch.config.rise_left_mm = v)
		_add_slider("nesumernost von", 0.0, 20.0, 0.25, c.drop_right_mm,
			func(v: float) -> void: Touch.config.drop_right_mm = v)
		_add_slider("najnizsi prah skoku", 0.0, 10.0, 0.25, c.j_min_mm,
			func(v: float) -> void: Touch.config.j_min_mm = v)
		_add_slider("navrat pred dalsim skokom", 0.0, 8.0, 0.25,
			c.hysteresis_mm,
			func(v: float) -> void: Touch.config.hysteresis_mm = v)
		_add_note("BEH")
		_add_slider("posun palca pre plnu rychlost vlavo", 2.0, 30.0, 0.5,
			c.run_saturation_left_mm,
			func(v: float) -> void: Touch.config.run_saturation_left_mm = v)
		_add_slider("posun palca pre plnu rychlost vpravo", 2.0, 30.0, 0.5,
			c.run_saturation_right_mm,
			func(v: float) -> void: Touch.config.run_saturation_right_mm = v)

	_add_note("MIERENIE")
	if c.aim_from_character:
		_add_slider("ako blizko k postave prestane mierit", 2.0, 30.0, 0.5,
			c.aim_origin_min_mm,
			func(v: float) -> void: Touch.config.aim_origin_min_mm = v)
	else:
		_add_slider("vacsie cislo = pokojnejsi terc", 3.0, 60.0, 0.5,
			c.aim_recenter_mm,
			func(v: float) -> void: Touch.config.aim_recenter_mm = v)

	_add_slider("rychlost postavy", 0.4, 2.5, 0.05, Tuning.player_speed_scale,
		func(v: float) -> void: Tuning.player_speed_scale = v)

	_add_note("NEPRIATELIA")
	_add_slider("rychlost bezcov", 0.2, 2.0, 0.05, Tuning.rusher_speed_scale,
		func(v: float) -> void: Tuning.rusher_speed_scale = v)
	_add_slider("rychlost strelcov", 0.2, 2.0, 0.05, Tuning.thrower_speed_scale,
		func(v: float) -> void: Tuning.thrower_speed_scale = v)
	_add_slider("na aku vzdialenost si bezec vsimne hraca (px)", 100.0, 1200.0,
		10.0, Tuning.enemy_detection_range,
		func(v: float) -> void: Tuning.enemy_detection_range = v)

	_add_note("ZONA PRE LAVY PALEC")
	_add_slider("sirka", 0.2, 0.8, 0.01, c.move_zone_width,
		func(v: float) -> void: Touch.config.move_zone_width = v)
	_add_slider("kolko zospodu patri miereniu", 0.0, 0.6, 0.01,
		c.move_zone_bottom,
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

	var free_mode := CheckButton.new()
	free_mode.text = "VOLNY POHYB (bez skoku)"
	free_mode.custom_minimum_size = Vector2(0, 56)
	free_mode.button_pressed = Touch.config.free_movement
	rows.add_child(free_mode)
	free_mode.toggled.connect(func(on: bool) -> void:
		Touch.config.free_movement = on
		# The level is built at startup and the two modes need different ones,
		# since platforms exist only for jumping. Reloading is the honest way
		# to switch; the config lives in an autoload and survives the reload.
		get_tree().reload_current_scene())

	var follow_mode := CheckButton.new()
	follow_mode.text = "POHYB KOPIRUJE PALEC"
	follow_mode.custom_minimum_size = Vector2(0, 56)
	follow_mode.button_pressed = Touch.config.free_move_follow
	rows.add_child(follow_mode)
	follow_mode.toggled.connect(func(on: bool) -> void:
		Touch.config.free_move_follow = on
		# Rebuilds the panel, since the two styles are tuned by different
		# sliders and leaving the wrong ones on screen invites tuning something
		# that is not connected to anything.
		get_tree().reload_current_scene())

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


## Heading between slider groups, so it is clear which of them belong together.
func _add_note(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.62, 0.78, 1.0))
	label.custom_minimum_size = Vector2(0, 34)
	rows.add_child(label)


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
		"free_movement           = %s" % c.free_movement,
		"free_move_y_ratio       = %s" % c.free_move_y_ratio,
		"free_move_follow        = %s" % c.free_move_follow,
		"free_move_gain          = %s" % c.free_move_gain,
		"player_speed_scale      = %s" % Tuning.player_speed_scale,
		"rusher_speed_scale      = %s" % Tuning.rusher_speed_scale,
		"thrower_speed_scale     = %s" % Tuning.thrower_speed_scale,
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


## Clears out enemies of one kind the moment their switch is turned on, so the
## effect is immediate rather than waiting for the current wave to die off.
## kind: 0 = RUSHER, 1 = THROWER (enemy.gd's Kind enum order).
func _despawn_kind(kind: int) -> void:
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.active and e.kind == kind:
			e.despawn()


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
	_draw_field_edges()

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

	draw_layer.draw_circle(a, 10.0, COL_LEFT)
	draw_layer.draw_line(a, p, COL_LEFT, 2.0)
	draw_layer.draw_arc(p, 26.0, 0.0, TAU, 24, COL_LEFT, 3.0)

	# Everything below draws the jump gesture: the threshold arc, the re-arm
	# line and the horizontal guide they are measured against. Free movement
	# has no jump, so they are describing a rule that is not in play - and a
	# curve drawn across the thumb while it is being used is simply in the way.
	if Touch.config.free_movement:
		return

	draw_layer.draw_line(Vector2(0.0, a.y), Vector2(vp.x * 0.5, a.y), COL_FAINT, 1.0)

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


## Top and bottom of the walkable field, in free movement.
##
## The limit is invisible by design - a solid ceiling filled half the screen
## with grey - but an invisible limit reads as the character getting stuck.
## A line says "this is the edge" instead.
func _draw_field_edges() -> void:
	if not Touch.config.free_movement:
		return
	var players := get_tree().get_nodes_in_group("player")
	var player := players[0] if not players.is_empty() else null
	if player == null:
		return
	var canvas: Transform2D = player.get_global_transform_with_canvas() \
		* player.global_transform.affine_inverse()
	var width: float = draw_layer.size.x
	for edge in [player.field_top, player.field_bottom]:
		var y: float = (canvas * Vector2(0.0, edge)).y
		draw_layer.draw_line(Vector2(0.0, y), Vector2(width, y),
			Color(0.55, 0.75, 1.0, 0.22), 2.0)


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
