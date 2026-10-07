extends Area2D

## Explosive pressure cauldron (2026-10-04) - Pavel's "lure them in" test.
##
## Takes Tuning.CAULDRON_HP hits from the axe or bullets (same target layer
## and hit() as a barrel). The last hit does NOT blow it up: it lights a fuse
## of Tuning.cauldron_fuse seconds. While it burns the pot shakes harder and
## harder, flashes red, whistles higher and higher, and - for testing - shows
## the seconds left as a number above it. Then it emits `exploded`; main.gd
## does the damage (enemies, barrels, the hero) because it knows who is near.
##
## Stays as a blackened wreck afterwards. Reset with the barrels.

signal exploded(feet: Vector2)

var hp: int = Tuning.CAULDRON_HP
var lit: bool = false
var spent: bool = false

var _fuse: float = 0.0
var _sprite: Sprite2D
var _label: Label
var _whistle: AudioStreamPlayer2D
var _block: StaticBody2D
var _block_shape: CollisionShape2D
var _flash: float = 0.0
var _art_height: float = 64.0
var _foot_margin: float = 0.0
var _whole_tex: Texture2D
var _whole_pos: Vector2
var _shadow: Node2D
const ShadowScript := preload("res://scripts/shadow.gd")


func _ready() -> void:
	# Frozen by the panel's ZMRAZIT SVET switch (the fuse stops).
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = Tuning.LAYER_TARGET
	collision_mask = 0
	monitoring = false

	var frames := SpriteSequence.load_frames(Tuning.CAULDRON_ART_DIR)
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not frames.is_empty():
		_sprite.texture = frames[0]
		_art_height = float(frames[0].get_height())
		_foot_margin = float(SpriteSequence.foot_margin(frames))
	add_child(_sprite)
	var s: float = Tuning.CAULDRON_SPRITE_SCALE
	_sprite.scale = Vector2.ONE * s
	_sprite.position = Vector2(0.0, -(_art_height * 0.5 - _foot_margin) * s)
	_whole_tex = _sprite.texture
	_whole_pos = _sprite.position

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Tuning.CAULDRON_HIT_SIZE
	shape.shape = rect
	shape.position = Vector2(0.0, -Tuning.CAULDRON_HIT_SIZE.y * 0.5)
	add_child(shape)

	# Blocks the hero's feet like a barrel - same strip arithmetic, see
	# barrel.gd _set_blocking (hero box 54 tall, depth +-26).
	_block = StaticBody2D.new()
	_block.collision_layer = Tuning.LAYER_PROP
	_block.collision_mask = 0
	add_child(_block)
	_block_shape = CollisionShape2D.new()
	_block_shape.shape = RectangleShape2D.new()
	_block.add_child(_block_shape)
	refit_block()

	# T31: ground shadow.
	_shadow = ShadowScript.new()
	add_child(_shadow)
	_shadow.setup(Vector2(0.0, -2.0), Tuning.CAULDRON_HIT_SIZE.x * 1.5)

	# The countdown number - a test aid, Pavel asked for it until the whistle
	# alone carries the warning.
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 40)
	_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.3))
	_label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_label.add_theme_constant_override(&"outline_size", 8)
	_label.position = Vector2(-14.0, -_art_height * s - 40.0)
	_label.visible = false
	add_child(_label)

	_whistle = AudioStreamPlayer2D.new()
	_whistle.bus = &"Sfx"
	_whistle.max_distance = 2000.0
	add_child(_whistle)


## The blocking strip, same arithmetic as barrel.gd _set_blocking: the feet
## box is Tuning.body_feet_height tall (T22), so the strip is placed to block
## exactly while a character's feet are within +-depth. Also called by main.gd
## when the panel changes the feet height.
func refit_block() -> void:
	var depth: float = Tuning.BARREL_BLOCK_DEPTH
	var h_box: float = clampf(Tuning.body_feet_height, 4.0, 54.0)
	var top: float = -depth
	var bottom: float = maxf(depth - h_box, top + 2.0)
	var r := _block_shape.shape as RectangleShape2D
	var w_fit: float = maxf(Tuning.CAULDRON_BLOCK_WIDTH
		- (Tuning.body_feet_width - Tuning.BODY_FEET_REF_WIDTH), 20.0)
	r.size = Vector2(w_fit, bottom - top)
	_block_shape.position = Vector2(0.0, (top + bottom) * 0.5)


## Whole again at `feet`. Cauldrons are reused, never freed.
func place(feet: Vector2) -> void:
	hp = Tuning.CAULDRON_HP
	lit = false
	spent = false
	_fuse = 0.0
	_flash = 0.0
	_label.visible = false
	_whistle.stop()
	_sprite.modulate = Color.WHITE
	_sprite.offset = Vector2.ZERO
	_sprite.texture = _whole_tex
	_sprite.scale = Vector2.ONE * Tuning.CAULDRON_SPRITE_SCALE
	_sprite.position = _whole_pos
	collision_layer = Tuning.LAYER_TARGET
	_block_shape.set_deferred("disabled", false)
	_shadow.show()
	show()
	global_position = feet
	z_index = Tuning.depth_z(feet.y - 27.0)


func hit() -> void:
	if lit or spent:
		return
	hp -= 1
	_flash = 1.0
	Sfx.play(&"barrel_hit", global_position)
	if hp <= 0:
		_light()


## The explosion of a neighbour lights this one too - with a short fuse, so a
## row of cauldrons goes off as a chain, not all in one frame.
func chain_light() -> void:
	if lit or spent:
		return
	hp = 0
	_light()
	_fuse = minf(_fuse, Tuning.CAULDRON_CHAIN_FUSE)


func _light() -> void:
	lit = true
	_fuse = Tuning.cauldron_fuse
	_label.visible = true
	var s: AudioStream = Sfx.pick(&"cauldron_whistle")
	if s != null and Sfx.enabled:
		if s is AudioStreamWAV:
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			s.loop_end = int(s.get_length() * s.mix_rate)
		_whistle.stream = s
		_whistle.pitch_scale = 1.0
		_whistle.play()


func _process(delta: float) -> void:
	_flash = maxf(_flash - delta * 6.0, 0.0)
	if not lit or spent:
		_sprite.modulate = Color.WHITE.lerp(Color(1.0, 0.5, 0.4), _flash * 0.7)
		return
	_fuse -= delta
	# 0 when just lit, 1 at the bang: everything ramps with it.
	var k: float = clampf(1.0 - _fuse / maxf(Tuning.cauldron_fuse, 0.01), 0.0, 1.0)
	_label.text = str(ceili(maxf(_fuse, 0.0)))
	var amp: float = 1.0 + k * 3.0
	_sprite.offset = Vector2(randf_range(-amp, amp), randf_range(-amp * 0.5, amp * 0.5))
	# Red pulse that speeds up as the fuse burns down.
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * (6.0 + k * 30.0))
	_sprite.modulate = Color.WHITE.lerp(Color(1.0, 0.35, 0.25), pulse * (0.3 + k * 0.6))
	_whistle.pitch_scale = 1.0 + k * Tuning.CAULDRON_WHISTLE_RISE
	if _fuse <= 0.0:
		_explode()


## The pot is gone; what stays is the last frame of the barrel burst
## (splintered wreck), burnt dark. Costs no art.
func _show_debris() -> void:
	var debris := SpriteSequence.load_frames(Tuning.BARREL_ART_DIR)
	if debris.is_empty():
		return
	var last: Texture2D = debris[debris.size() - 1]
	var s: float = Tuning.BARREL_SPRITE_SCALE
	_sprite.texture = last
	_sprite.scale = Vector2.ONE * s
	_sprite.position = Vector2(0.0, -(float(last.get_height()) * 0.5
		- float(SpriteSequence.foot_margin(debris))) * s)


func _explode() -> void:
	spent = true
	lit = false
	_label.visible = false
	_whistle.stop()
	_sprite.offset = Vector2.ZERO
	# The wreck: burnt black, no longer a target, no longer in the way.
	_sprite.modulate = Color(0.25, 0.22, 0.2)
	_show_debris()
	_shadow.hide()
	set_deferred("collision_layer", 0)
	_block_shape.set_deferred("disabled", true)
	Sfx.play(&"explosion", global_position)
	exploded.emit(global_position)
