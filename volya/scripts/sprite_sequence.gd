class_name SpriteSequence
extends RefCounted

## Loads a PNG sequence rendered by tools/blender_render_sprites.py.
##
## The renderer writes plain numbered PNGs into a folder rather than a sprite
## sheet, because a folder can be re-rendered and re-read without anything in
## the game having to know how many frames there are this time.


## All PNG files in a folder, in name order. The renderer zero-pads the frame
## number, so plain alphabetical sorting is also frame order.
static func png_files(path: String) -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open(path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not dir.current_is_dir() and entry.to_lower().ends_with(".png"):
			result.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	result.sort()
	return result


## Frame paths listed by the manifest the render pass writes, or an empty array
## if there is none.
##
## Godot converts images to its own format on export, so the original .png
## files are not present in the installed game and listing the folder returns
## nothing. That fails only on the device, never in the editor. The manifest is
## a script, which does survive the export.
static func manifest_paths(path: String) -> PackedStringArray:
	var manifest_path := path.path_join("frames.gd")
	if not ResourceLoader.exists(manifest_path):
		return PackedStringArray()
	var script := load(manifest_path)
	if script == null:
		return PackedStringArray()
	var lister = script.new()
	if lister == null or not (&"FRAMES" in lister):
		return PackedStringArray()
	var out := PackedStringArray()
	for entry in lister.FRAMES:
		out.append(String(entry))
	return out


static func load_frames(path: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []

	var listed := manifest_paths(path)
	if listed.is_empty():
		# No manifest: fall back to reading the folder, which works in the
		# editor and is enough for a sequence dropped in by hand.
		for file_name in png_files(path):
			listed.append(path.path_join(file_name))

	for full_path in listed:
		var tex := load(full_path) as Texture2D
		if tex != null:
			frames.append(tex)
	return frames


## First folder under `root` that actually contains PNGs, `root` itself included.
static func find_sequence_dir(root: String) -> String:
	if not png_files(root).is_empty():
		return root
	var dir := DirAccess.open(root)
	if dir == null:
		return ""
	var names: Array[String] = []
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			names.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	names.sort()
	for sub in names:
		var candidate := root.path_join(sub)
		if not png_files(candidate).is_empty():
			return candidate
	return ""


static func build_frames(frames: Array[Texture2D], anim: String,
		fps: float, loop: bool = true) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for tex in frames:
		sf.add_frame(anim, tex)
	if sf.has_animation(&"default") and anim != "default":
		sf.remove_animation(&"default")
	return sf


## Index of the frame closest to standing still.
##
## A run cycle has no standing pose, so freezing on frame zero leaves the
## character balanced on one leg and leaning. The narrowest frame is the one
## where the legs have passed each other, which is the least wrong thing to
## hold until a real idle animation exists.
static func most_upright_frame(frames: Array[Texture2D]) -> int:
	var best_index := 0
	var best_width := 1 << 30
	for index in frames.size():
		var image := frames[index].get_image()
		if image == null:
			continue
		if image.is_compressed() and image.decompress() != OK:
			continue
		var left := image.get_width()
		var right := -1
		for x in image.get_width():
			for y in image.get_height():
				if image.get_pixel(x, y).a > 0.5:
					left = mini(left, x)
					right = maxi(right, x)
					break
		var width := right - left
		if right >= 0 and width < best_width:
			best_width = width
			best_index = index
	return best_index


## How far the lowest opaque pixel sits above the bottom edge of the canvas.
##
## The renderer auto-frames the model with a margin, so the feet are not on the
## bottom row and a sprite pinned by its edge floats above the ground. Measured
## across every frame, because a run cycle has frames where the lowest foot is
## higher than in others and only the lowest one defines the ground contact.
static func foot_margin(frames: Array[Texture2D]) -> int:
	var lowest_gap := 1 << 30
	for tex in frames:
		var image := tex.get_image()
		if image == null:
			continue
		# An imported texture can come back in a GPU-compressed format, and
		# get_pixel() is not allowed on one.
		if image.is_compressed():
			if image.decompress() != OK:
				continue
		var height := image.get_height()
		var width := image.get_width()
		var gap := height
		for y in range(height - 1, -1, -1):
			var opaque := false
			for x in range(width):
				if image.get_pixel(x, y).a > 0.5:
					opaque = true
					break
			if opaque:
				gap = height - 1 - y
				break
		lowest_gap = mini(lowest_gap, gap)
	return 0 if lowest_gap == (1 << 30) else lowest_gap
