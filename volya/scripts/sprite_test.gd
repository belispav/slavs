extends Node2D

## Sprite pipeline test scene.
## Loads a PNG sequence rendered by tools/blender_render_sprites.py and plays it
## next to the current grey player box, so scale and readability can be judged.
##
## Klávesy:  ←/→ zmena FPS   ↑/↓ zmena mierky   MEDZERNÍK pauza   R znovunačítať

const ART_ROOT := "res://art"
const GROUND_Y := 520.0
const BOX_SIZE := Vector2(30, 54)   # must match player.gd SIZE

var frames: Array[Texture2D] = []
var source_dir: String = ""
var sprite: Sprite2D
var info: Label

var fps: float = 10.0
var sprite_scale: float = 1.0
var playing: bool = true
var _time: float = 0.0
var _r_was_down: bool = false


func _ready() -> void:
	sprite = Sprite2D.new()
	# Match the game: Nearest, so the preview shows the pixels as shipped.
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	info = Label.new()
	info.position = Vector2(24, 20)
	add_child(info)

	_reload()


func _reload() -> void:
	frames.clear()
	# Prefer the folder the game itself uses; fall back to any sequence under
	# res://art so an older render can still be inspected.
	source_dir = Tuning.PLAYER_ART_DIR
	if SpriteSequence.png_files(source_dir).is_empty():
		source_dir = SpriteSequence.find_sequence_dir(ART_ROOT)
	if source_dir != "":
		frames = SpriteSequence.load_frames(source_dir)
	_time = 0.0
	_apply_frame()
	queue_redraw()


func _process(delta: float) -> void:
	if playing and frames.size() > 1:
		_time += delta
	_apply_frame()
	_read_keys(delta)
	_update_info()


func _apply_frame() -> void:
	if frames.is_empty():
		sprite.texture = null
		return
	var index: int = int(_time * fps) % frames.size()
	sprite.texture = frames[index]
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	var h: float = sprite.texture.get_height() * sprite_scale
	sprite.position = Vector2(760.0, GROUND_Y - h * 0.5)


func _read_keys(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		playing = not playing
	if Input.is_physical_key_pressed(KEY_RIGHT):
		fps = minf(fps + delta * 8.0, 60.0)
	if Input.is_physical_key_pressed(KEY_LEFT):
		fps = maxf(fps - delta * 8.0, 1.0)
	if Input.is_physical_key_pressed(KEY_UP):
		sprite_scale = minf(sprite_scale + delta * 1.5, 8.0)
	if Input.is_physical_key_pressed(KEY_DOWN):
		sprite_scale = maxf(sprite_scale - delta * 1.5, 0.1)
	var r_down: bool = Input.is_physical_key_pressed(KEY_R)
	if r_down and not _r_was_down:
		_reload()
	_r_was_down = r_down


func _update_info() -> void:
	if frames.is_empty():
		info.text = "ŽIADNE PNG SÚBORY.\n\n" \
			+ "Vyrenderuj sekvenciu skriptom tools/blender_render_sprites.py\n" \
			+ "a skopíruj PNG súbory do priečinka volya/art/<nazov>/.\n" \
			+ "Potom sa vráť do Godotu (naimportuje ich sám) a stlač R."
		return
	var tex: Texture2D = frames[0]
	info.text = "priečinok: %s\nsnímok: %d   veľkosť: %d x %d px\nFPS: %.1f   mierka: %.2f   výška v hre: %.0f px\n%s" % [
		source_dir, frames.size(), tex.get_width(), tex.get_height(),
		fps, sprite_scale, tex.get_height() * sprite_scale,
		"prehráva sa" if playing else "PAUZA"]


func _draw() -> void:
	# ground + 32 px grid for judging size
	for x in range(0, 1281, 32):
		draw_line(Vector2(x, GROUND_Y - 320.0), Vector2(x, GROUND_Y),
			Color(1, 1, 1, 0.05), 1.0)
	draw_line(Vector2(0, GROUND_Y), Vector2(1280, GROUND_Y),
		Color(0.9, 0.9, 1.0, 0.5), 2.0)

	# current player hitbox, for scale comparison
	var box_pos := Vector2(560.0 - BOX_SIZE.x * 0.5, GROUND_Y - BOX_SIZE.y)
	draw_rect(Rect2(box_pos, BOX_SIZE), Color(0.78, 0.80, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(516.0, GROUND_Y + 28.0),
		"teraz v hre (54 px)", HORIZONTAL_ALIGNMENT_LEFT, -1, 18,
		Color(0.7, 0.72, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(700.0, GROUND_Y + 28.0),
		"z Blenderu", HORIZONTAL_ALIGNMENT_LEFT, -1, 18,
		Color(0.7, 0.72, 0.8))
