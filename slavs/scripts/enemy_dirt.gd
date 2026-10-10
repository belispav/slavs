class_name EnemyDirt
extends RefCounted

## Package 3 - enemy variety by dirt (Pavel 2026-10-09).
##
## At game start every enemy kind gets DIRT_VARIANTS copies of its whole SpriteFrames
## in which a few small mud-brown spots are blended onto pixels that are already
## drawn. The spots sit at the same canvas pixels on every frame of one variant (only
## where that frame is opaque), so they do not flicker; they may "swim" a little on the
## body while walking, which is why they stay small. At spawn an enemy picks one variant
## at random: no per-frame cost, no shader, no PixelLab credits.
##
## Baking uses only native Image calls per frame (blend_rect + blit_rect_mask), the
## per-pixel GDScript loop runs once per kind on the reference frame.
## Settings change (panel): the kinds are re-baked lazily at the next spawn.

## kind key -> {sheet: SpriteFrames (clean), ref: Texture2D, death: Array}
static var _clean: Dictionary = {}
## kind key -> {sig: Array, sheets: Array[SpriteFrames], deaths: Array[Array]}
static var _baked: Dictionary = {}


## Called by every enemy node when its sprite is built; only the first one per kind counts.
## `ref` = a frame whose opaque pixels say where the body is (the kind's first idle frame).
static func register(key: StringName, sheet: SpriteFrames, ref: Texture2D, death: Array) -> void:
	if _clean.has(key) or sheet == null or ref == null:
		return
	_clean[key] = {"sheet": sheet, "ref": ref, "death": death}
	_rebake(key)


## {sheet: SpriteFrames, death: Array} of a random variant, or {} when the clean look
## should be used (switch off, no spots, kind unknown).
static func pick(key: StringName) -> Dictionary:
	if not Tuning.dirt_on or not _clean.has(key):
		return {}
	var spots: int = _spots()
	if spots <= 0:
		return {}
	if not _baked.has(key) or _baked[key]["sig"] != _signature():
		_rebake(key)
	var baked: Dictionary = _baked.get(key, {})
	if baked.is_empty() or baked["sheets"].is_empty():
		return {}
	var i: int = randi() % baked["sheets"].size()
	return {"sheet": baked["sheets"][i], "death": baked["deaths"][i]}


## Number of spots per variant: the panel slider times NAHODNOST (0 = clean enemies).
static func _spots() -> int:
	return int(round(float(Tuning.dirt_spots) * clampf(Tuning.random_strength, 0.0, 2.0)))


static func _signature() -> Array:
	return [_spots(), Tuning.dirt_weight]


static func _rebake(key: StringName) -> void:
	var src: Dictionary = _clean[key]
	var spots: int = _spots()
	var entry := {"sig": _signature(), "sheets": [], "deaths": []}
	_baked[key] = entry
	if spots <= 0:
		return
	var sheet: SpriteFrames = src["sheet"]
	var ref_img: Image = _image_of(src["ref"])
	if ref_img == null:
		return
	var body: Array[Vector2i] = _opaque_pixels(ref_img)
	if body.is_empty():
		return
	# Source images are decoded once and shared by all variants.
	var images: Dictionary = {}    # Texture2D -> Image (RGBA8)
	for anim in sheet.get_animation_names():
		for f in sheet.get_frame_count(anim):
			var tex: Texture2D = sheet.get_frame_texture(anim, f)
			if not images.has(tex):
				images[tex] = _image_of(tex)
	for tex in src["death"]:
		if not images.has(tex):
			images[tex] = _image_of(tex)
	for v in Tuning.DIRT_VARIANTS:
		var layer: Image = _make_layer(ref_img.get_size(), body, 7919 * (v + 1) + 13, spots)
		var dirty: Dictionary = {}     # Texture2D -> ImageTexture, so a shared frame is baked once
		var new_sheet := SpriteFrames.new()
		for anim in sheet.get_animation_names():
			new_sheet.add_animation(anim)
			new_sheet.set_animation_speed(anim, sheet.get_animation_speed(anim))
			new_sheet.set_animation_loop(anim, sheet.get_animation_loop(anim))
			for f in sheet.get_frame_count(anim):
				var tex: Texture2D = sheet.get_frame_texture(anim, f)
				new_sheet.add_frame(anim, _dirty_of(tex, images, layer, dirty),
					sheet.get_frame_duration(anim, f))
		if new_sheet.has_animation(&"default") and not sheet.has_animation(&"default"):
			new_sheet.remove_animation(&"default")
		var death: Array = []
		for tex in src["death"]:
			death.append(_dirty_of(tex, images, layer, dirty))
		entry["sheets"].append(new_sheet)
		entry["deaths"].append(death)


static func _image_of(tex: Texture2D) -> Image:
	if tex == null:
		return null
	var img: Image = tex.get_image()
	if img == null:
		return null
	if img.is_compressed() and img.decompress() != OK:
		return null
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	return img


static func _opaque_pixels(img: Image) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.5:
				out.append(Vector2i(x, y))
	return out


## Transparent image the size of the canvas with the mud spots: colour = DIRT_COLOR,
## alpha = how strongly the spot replaces the pixel underneath. Each spot is 1 pixel,
## half of them get a 1-2 pixel smudge next to them.
static func _make_layer(size: Vector2i, body: Array[Vector2i], seed_value: int, spots: int) -> Image:
	var layer := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for _s in spots:
		var p: Vector2i = body[rng.randi() % body.size()]
		_put(layer, p, rng.randf_range(0.8, 1.2))
		var extra: int = [0, 0, 1, 2][rng.randi() % 4]
		for _e in extra:
			_put(layer, p + dirs[rng.randi() % 4], rng.randf_range(0.6, 1.0))
	return layer


static func _put(layer: Image, p: Vector2i, strength: float) -> void:
	if p.x < 0 or p.y < 0 or p.x >= layer.get_width() or p.y >= layer.get_height():
		return
	var c: Color = Tuning.DIRT_COLOR
	c.a = clampf(Tuning.dirt_weight * strength, 0.0, 1.0)
	layer.set_pixel(p.x, p.y, c)


## The frame with the layer blended in, but only on its opaque pixels. A canvas of a
## different size than the layer (should not happen) stays clean.
static func _dirty_of(tex: Texture2D, images: Dictionary, layer: Image, done: Dictionary) -> Texture2D:
	if done.has(tex):
		return done[tex]
	var src: Image = images.get(tex)
	var result: Texture2D = tex
	if src != null and src.get_size() == layer.get_size():
		var rect := Rect2i(Vector2i.ZERO, src.get_size())
		var blended: Image = src.duplicate()
		blended.blend_rect(layer, rect, Vector2i.ZERO)
		var out: Image = src.duplicate()
		out.blit_rect_mask(blended, src, rect, Vector2i.ZERO)
		result = ImageTexture.create_from_image(out)
	done[tex] = result
	return result
