extends Area2D

## A breakable barrel (2026-10-03) - the first destructible prop.
##
## Sits on the field, takes Tuning.BARREL_HP hits from the axe or from
## bullets (same layer and same hit() method as an enemy's hurtbox), shakes
## and flashes on every hit, then plays the PixelLab "burst apart" clip and
## stays on the ground as a wreck. It does not block movement: a prop the
## hero snags on would be a controls problem, and controls come first.

signal broken(at: Vector2)
## Every hit: where the barrel stands and whether this one broke it.
signal damaged(feet: Vector2, broke: bool)

## Which prop this is: the same script serves barrels and ceramic pots (2026-10-09).
## main.gd sets these BEFORE add_child. A one-frame folder has no break clip yet,
## so breaking just hides the picture (preview of the pot art).
var art_dir: String = Tuning.BARREL_ART_DIR
var hit_size: Vector2 = Tuning.BARREL_HIT_SIZE
var _single_frame: bool = false

var hp: int = Tuning.BARREL_HP
var is_broken: bool = false

var _sprite: AnimatedSprite2D
var _shape: CollisionShape2D
## What stops the hero. A separate body, because the hit Area above is a
## target (bullets, axe) and must not push anything.
var _block: StaticBody2D
var _block_shape: CollisionShape2D
## What _set_blocking last applied, so a panel change can be re-applied.
var _block_depth: float = 0.0
var _block_width: float = 0.0
var _shake: float = 0.0
var _flash: float = 0.0
var _art_height: float = 64.0
var _foot_margin: float = 0.0
var _shadow: Node2D
const ShadowScript := preload("res://scripts/shadow.gd")


func _ready() -> void:
	collision_layer = Tuning.LAYER_TARGET
	collision_mask = 0
	monitoring = false

	var frames := SpriteSequence.load_frames(art_dir)
	_single_frame = frames.size() <= 1
	var sheet := SpriteFrames.new()
	sheet.remove_animation(&"default")
	sheet.add_animation(&"whole")
	sheet.add_animation(&"break")
	sheet.set_animation_loop(&"break", false)
	sheet.set_animation_speed(&"break", Tuning.BARREL_BREAK_FPS)
	if not frames.is_empty():
		sheet.add_frame(&"whole", frames[0])
		for tex in frames:
			sheet.add_frame(&"break", tex)
		_art_height = float(frames[0].get_height())
		_foot_margin = float(SpriteSequence.foot_margin(frames))

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = sheet
	_sprite.animation = &"whole"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	_shape.shape = rect
	add_child(_shape)

	_block = StaticBody2D.new()
	_block.collision_layer = Tuning.LAYER_PROP
	_block.collision_mask = 0
	add_child(_block)
	_block_shape = CollisionShape2D.new()
	_block_shape.shape = RectangleShape2D.new()
	_block.add_child(_block_shape)
	_fit()
	_set_blocking(Tuning.BARREL_BLOCK_DEPTH)
	# T31: ground shadow, wider than the hit box (the barrel bulges).
	_shadow = ShadowScript.new()
	add_child(_shadow)
	_shadow.setup(Vector2(0.0, -2.0), hit_size.x * 1.5)


## The node's origin is the barrel's FEET - where it stands on the field -
## so depth sorting and placement both read off one number.
func _fit() -> void:
	var s: float = Tuning.BARREL_SPRITE_SCALE
	_sprite.scale = Vector2.ONE * s
	# Bottom of the drawing (not of the canvas) on the origin.
	_sprite.position = Vector2(0.0, -(_art_height * 0.5 - _foot_margin) * s)
	var rect := _shape.shape as RectangleShape2D
	rect.size = hit_size
	_shape.position = Vector2(0.0, -hit_size.y * 0.5)


## Blocks the hero's FEET within `depth` above or below the barrel's own feet.
##
## The hero's collision box is 54 tall and hangs from his feet, so a box
## overlapping it would block him whenever any part of his body overlapped -
## including when he stands well behind the barrel. The blocker is instead a
## thin strip placed so that "boxes overlap" works out to exactly "feet within
## +-depth" - the arithmetic is below.
func _set_blocking(depth: float) -> void:
	_block_depth = depth
	_block_width = Tuning.barrel_block_width
	# Hero box spans [hf - H, hf] (H = 54). Strip spans [t, b]. They overlap
	# when hf > t and hf - H < b, i.e. hf in (t, b + H). For hf in
	# (bf - depth, bf + depth): t = bf - depth, b = bf + depth - H. Needs
	# 2*depth > H; below that the strip is clamped to 2 units.
	var h_box: float = clampf(Tuning.body_feet_height, 4.0, 54.0)
	var top: float = -depth
	var bottom: float = maxf(depth - h_box, top + 2.0)
	var r := _block_shape.shape as RectangleShape2D
	# The strip was measured against a 30 px wide body: a wider body stops
	# earlier, so the strip is narrower by the difference (same stopping gap).
	var w_fit: float = maxf(_block_width - (Tuning.body_feet_width - Tuning.BODY_FEET_REF_WIDTH), 20.0)
	r.size = Vector2(w_fit, bottom - top)
	_block_shape.position = Vector2(0.0, (top + bottom) * 0.5)


## main.gd calls this when the panel changes the feet height (T22): the strip
## is computed from it.
func refit_block() -> void:
	_set_blocking(_block_depth)


## Whole again and stood at `feet`. Barrels are reused, never freed.
## `block_depth` > 0 overrides how far in depth it blocks (the wall uses it
## so neighbouring barrels close every gap).
func place(feet: Vector2, block_depth: float = 0.0) -> void:
	_set_blocking(block_depth if block_depth > 0.0 else Tuning.BARREL_BLOCK_DEPTH)
	_block_shape.set_deferred("disabled", false)
	hp = Tuning.BARREL_HP
	is_broken = false
	_shake = 0.0
	_flash = 0.0
	collision_layer = Tuning.LAYER_TARGET
	_sprite.animation = &"whole"
	_sprite.stop()
	_sprite.show()
	_shadow.show()
	show()
	global_position = feet
	# Depth from where a body standing here would have its ORIGIN - the
	# player and the enemies sort by their collision-box centre, half a
	# player box above the feet - so the barrel sorts against them fairly.
	z_index = Tuning.depth_z(feet.y - 27.0)


## Destroyed outright - a cauldron's blast.
func smash() -> void:
	if is_broken:
		return
	hp = 1
	hit()


func hit() -> void:
	if is_broken:
		return
	hp -= 1
	_shake = 0.18
	_flash = 1.0
	damaged.emit(global_position, hp <= 0)
	Sfx.play(&"barrel_break" if hp <= 0 else &"barrel_hit", global_position)
	if hp <= 0:
		is_broken = true
		set_deferred("collision_layer", 0)
		# The wreck is flat - walk over it.
		_block_shape.set_deferred("disabled", true)
		_shadow.hide()
		if _single_frame:
			_sprite.hide()
		else:
			_sprite.play(&"break")
		broken.emit(global_position)


func _process(delta: float) -> void:
	if _block_width != Tuning.barrel_block_width:
		_set_blocking(_block_depth)
	_flash = maxf(_flash - delta * 6.0, 0.0)
	_sprite.modulate = Color.WHITE.lerp(Color(1.0, 0.55, 0.45), _flash * 0.7)
	if _shake > 0.0:
		_shake = maxf(_shake - delta, 0.0)
		_sprite.offset.x = 1.0 if int(_shake * 60.0) % 2 == 0 else -1.0
	else:
		_sprite.offset.x = 0.0
