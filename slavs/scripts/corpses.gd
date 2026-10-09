extends Node2D

## Package 2 "Smrt nepriatela" - A9 (death with a punchline) and T36 (how the
## body disappears).
##
## A killed enemy goes back to the pool at once (enemy.gd despawn), so what the
## player sees falling is NOT the enemy: it is a separate picture.
##   - With a death clip (rusher, gunman: PixelLab): the clip plays at
##     corpse_anim_fps while the body hops a little along the blow and slides,
##     then the last frame (lying) stays.
##   - Without a clip: the frame the enemy died in is thrown along the blow,
##     spins onto its back, bounces once and lies.
##   - The brute does not fall: burst() cuts its last frame into pieces that
##     fly apart (plus blood and a puff of smoke).
## Then a body vanishes (puff of smoke, or a fade).
## Every value is jittered per body (Tuning.jitter, panel NAHODNOST).
## Corpses are pooled (MAX_CORPSES); a full field recycles the oldest.
##
## Same ground/height trick as fx.gd: g = spot on the ground (feet), h = height
## above it (of the body centre without a clip, of the feet with one).
## Game-time delta, so hit-stop and slow-motion slow the flight too.

const ENEMY_SCRIPT: GDScript = preload("res://scripts/enemy.gd")

const MAX_CORPSES: int = 24
const GRAVITY: float = 900.0
## Flight at power 1.0 (world units / second). The panel slider scales both.
const FLY_SPEED: float = 230.0
const FLY_UP: float = 210.0
const SPIN_MIN: float = 2.6
const SPIN_MAX: float = 3.6
## Share of the downward speed that survives the one bounce (no-clip bodies).
const BOUNCE: float = 0.32
const LAND_EASE: float = 14.0
const FADE_TIME: float = 0.6
const SMOKE_FADE_TIME: float = 0.12

## Burst (brute): the opaque part of the frame is cut into BURST_COLS x BURST_ROWS.
const BURST_COLS: int = 4
const BURST_ROWS: int = 6
const BURST_SPEED_MIN: float = 120.0
const BURST_SPEED_MAX: float = 340.0
const BURST_LIFT_MIN: float = 60.0
const BURST_LIFT_MAX: float = 260.0
const BURST_LAY_MIN: float = 0.5
const BURST_LAY_MAX: float = 1.0
const BURST_FADE: float = 0.3
const MAX_PIECES: int = 96

var fx   # fx.gd - landing blood, smoke puff

var _live: Array = []     # active corpses (Dictionary each)
var _spare: Array = []    # pivots ready for reuse
var _pieces: Array = []   # active burst pieces (Dictionary each)
var _piece_spare: Array = []
var _cell_cache: Dictionary = {}   # texture -> {box: Rect2i, cells: Array[bool]}


func setup(fx_node) -> void:
	fx = fx_node


## `tex` the frame the enemy died in, `flip` its flip_h, `art_scale` the
## sprite scale, `off` the sprite position relative to the FEET, `body_h` the
## drawn height, `dir` the way the blow travelled (zero = unknown, `side` is
## then +1/-1 away from the hero), `frames` the enemy's death clip (may be empty).
## `forward`: the clip topples the way the enemy faces (gunman), not away from the blow.
func spawn(tex: Texture2D, flip: bool, art_scale: Vector2, off: Vector2, feet: Vector2, body_h: float, dir: Vector2, side: float, frames: Array, forward: bool = false) -> void:
	if not Tuning.fx_corpse_on or tex == null:
		return
	if _live.size() >= MAX_CORPSES:
		_release(0)
	var sx: float = signf(dir.x) if absf(dir.x) > 0.2 else side
	if sx == 0.0:
		sx = 1.0
	var power: float = Tuning.jitter(Tuning.corpse_power, Tuning.RAND_POWER)
	var anim: bool = frames.size() > 1
	var fly: float = 0.3 if (anim and forward) else 1.0
	var pivot: Node2D
	var spr: Sprite2D
	if _spare.is_empty():
		pivot = Node2D.new()
		spr = Sprite2D.new()
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pivot.add_child(spr)
		add_child(pivot)
	else:
		pivot = _spare.pop_back()
		spr = pivot.get_child(0)
	pivot.show()
	pivot.modulate = Color.WHITE
	spr.material = null
	spr.scale = art_scale
	if anim:
		# Pivot at the feet. The clip is exported falling toward +x, so it only
		# has to be mirrored when the blow came the other way.
		spr.texture = frames[0]
		# A `forward` clip (gunman) topples the way the enemy faces, so it follows
		# his own flip and only slides a little in the blow's direction.
		spr.flip_h = flip if forward else sx < 0.0
		spr.position = Vector2(0.0, off.y)
	else:
		spr.texture = tex
		spr.flip_h = flip
		# Rotation pivot = middle of the body, so it spins like a body.
		spr.position = off + Vector2(0.0, body_h * 0.5)
	var c := {
		"pivot": pivot, "spr": spr,
		"g": feet,
		"vel": Vector2(sx * FLY_SPEED * power * randf_range(0.8, 1.2) * fly,
			dir.y * FLY_SPEED * 0.4 * power * fly),
		"h": 0.0 if anim else body_h * 0.5,
		"vh": FLY_UP * power * randf_range(0.8, 1.2) * fly,
		"rest_h": 0.0 if anim else body_h * 0.2,
		"ang": 0.0,
		"w": 0.0 if anim else -sx * randf_range(SPIN_MIN, SPIN_MAX) * clampf(power, 0.4, 1.5),
		"rest_ang": 0.0 if anim else -sx * (PI * 0.5 + randf_range(-0.12, 0.12)),
		"phase": 0,        # 0 flying, 1 after the bounce, 2 lying, 3 vanishing
		"t": 0.0,
		"anim": anim, "frames": frames, "ta": 0.0, "fi": 0,
		"fps": maxf(Tuning.jitter(Tuning.corpse_anim_fps, Tuning.RAND_ANIM), 1.0),
		"linger": maxf(Tuning.jitter(Tuning.corpse_linger, Tuning.RAND_LINGER), 0.0),
		"white": Tuning.jitter(Tuning.hit_white_ms, Tuning.RAND_WHITE) / 1000.0 if Tuning.fx_white_on else 0.0,
	}
	if c["white"] > 0.0:
		spr.material = ENEMY_SCRIPT._get_white_material()
	_live.append(c)
	_place(c)


## The brute bursts apart instead of falling: pieces of its own last frame fly
## away from the middle of the body, land, lie a moment and fade.
func burst(tex: Texture2D, flip: bool, art_scale: Vector2, off: Vector2, feet: Vector2, body_h: float, side: float) -> void:
	if not Tuning.fx_corpse_on or tex == null:
		return
	var info: Dictionary = _cell_info(tex)
	var box: Rect2i = info["box"]
	if box.size.x <= 0 or box.size.y <= 0:
		return
	var cells: Array = info["cells"]
	var cw: float = float(box.size.x) / BURST_COLS
	var ch: float = float(box.size.y) / BURST_ROWS
	var half := Vector2(tex.get_width(), tex.get_height()) * 0.5
	var centre: Vector2 = feet + Vector2(0.0, -body_h * 0.5)
	var power: float = Tuning.jitter(Tuning.corpse_power, Tuning.RAND_POWER)
	for cy in BURST_ROWS:
		for cx in BURST_COLS:
			if not cells[cy * BURST_COLS + cx]:
				continue
			if _pieces.size() >= MAX_PIECES:
				_release_piece(0)
			var region := Rect2(box.position.x + cx * cw, box.position.y + cy * ch, cw, ch)
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = region
			var local: Vector2 = region.get_center() - half
			if flip:
				local.x = -local.x
			var world: Vector2 = feet + off + local * art_scale
			var node: Sprite2D
			if _piece_spare.is_empty():
				node = Sprite2D.new()
				node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				add_child(node)
			else:
				node = _piece_spare.pop_back()
			node.show()
			node.modulate = Color.WHITE
			node.texture = at
			node.flip_h = flip
			node.scale = art_scale
			node.rotation = 0.0
			var away: Vector2 = (world - centre)
			if away.length() < 1.0:
				away = Vector2(side, -0.3)
			away = away.normalized()
			var speed: float = randf_range(BURST_SPEED_MIN, BURST_SPEED_MAX) * power
			_pieces.append({
				"node": node,
				"g": Vector2(world.x, feet.y),
				"h": maxf(feet.y - world.y, 0.0),
				"vel": Vector2(away.x * speed, randf_range(-35.0, 35.0)),
				"vh": -away.y * speed * 0.5 + randf_range(BURST_LIFT_MIN, BURST_LIFT_MAX) * power,
				"w": randf_range(-9.0, 9.0),
				"phase": 0, "t": 0.0,
				"lay": Tuning.jitter(randf_range(BURST_LAY_MIN, BURST_LAY_MAX), Tuning.RAND_LINGER * 0.5),
			})
			_place_piece(_pieces[_pieces.size() - 1])
	if fx != null:
		fx.body_hit(feet, body_h, side, true, Tuning.BURST_BLOOD)
		fx.corpse_puff(feet + Vector2(0.0, -body_h * 0.4))


## Opaque box of the frame and which cells of the BURST grid inside it have
## any pixels. Cached per texture (the brute has only a few frames).
func _cell_info(tex: Texture2D) -> Dictionary:
	if _cell_cache.has(tex):
		return _cell_cache[tex]
	var res := {"box": Rect2i(), "cells": []}
	var img: Image = tex.get_image()
	if img != null:
		if img.is_compressed():
			img.decompress()
		var used: Rect2i = img.get_used_rect()
		res["box"] = used
		var cells: Array = []
		for cy in BURST_ROWS:
			for cx in BURST_COLS:
				var x0: int = used.position.x + int(float(cx) * used.size.x / BURST_COLS)
				var x1: int = used.position.x + int(float(cx + 1) * used.size.x / BURST_COLS)
				var y0: int = used.position.y + int(float(cy) * used.size.y / BURST_ROWS)
				var y1: int = used.position.y + int(float(cy + 1) * used.size.y / BURST_ROWS)
				var any: bool = false
				for y in range(y0, maxi(y1, y0 + 1)):
					for x in range(x0, maxi(x1, x0 + 1)):
						if img.get_pixel(clampi(x, 0, img.get_width() - 1),
								clampi(y, 0, img.get_height() - 1)).a >= 0.5:
							any = true
							break
					if any:
						break
				cells.append(any)
		res["cells"] = cells
	_cell_cache[tex] = res
	return res


func _release(i: int) -> void:
	var c: Dictionary = _live[i]
	var pivot: Node2D = c["pivot"]
	pivot.hide()
	_spare.append(pivot)
	_live.remove_at(i)


func _release_piece(i: int) -> void:
	var p: Dictionary = _pieces[i]
	var node: Sprite2D = p["node"]
	node.hide()
	_piece_spare.append(node)
	_pieces.remove_at(i)


func clear() -> void:
	while not _live.is_empty():
		_release(_live.size() - 1)
	while not _pieces.is_empty():
		_release_piece(_pieces.size() - 1)


func _process(delta: float) -> void:
	var i: int = _live.size() - 1
	while i >= 0:
		var c: Dictionary = _live[i]
		_step(c, delta)
		if c["phase"] == 4:
			_release(i)
		else:
			_place(c)
		i -= 1
	var j: int = _pieces.size() - 1
	while j >= 0:
		var p: Dictionary = _pieces[j]
		_step_piece(p, delta)
		if p["phase"] == 3:
			_release_piece(j)
		else:
			_place_piece(p)
		j -= 1


func _step_piece(p: Dictionary, delta: float) -> void:
	var node: Sprite2D = p["node"]
	if p["phase"] == 0:
		p["g"] += p["vel"] * delta
		p["vh"] -= GRAVITY * delta
		p["h"] += p["vh"] * delta
		node.rotation += p["w"] * delta
		if p["h"] <= 0.0 and p["vh"] < 0.0:
			p["h"] = 0.0
			p["phase"] = 1
			p["t"] = 0.0
			p["vel"] = Vector2.ZERO
	elif p["phase"] == 1:
		p["t"] += delta
		if p["t"] >= p["lay"]:
			p["phase"] = 2
			p["t"] = 0.0
	elif p["phase"] == 2:
		p["t"] += delta
		node.modulate.a = clampf(1.0 - p["t"] / BURST_FADE, 0.0, 1.0)
		if p["t"] >= BURST_FADE:
			p["phase"] = 3


func _place_piece(p: Dictionary) -> void:
	var node: Sprite2D = p["node"]
	var g: Vector2 = p["g"]
	node.position = g + Vector2(0.0, -float(p["h"]))
	node.z_index = Tuning.depth_z(g.y) - (2 if p["phase"] >= 1 else 0)


func _step(c: Dictionary, delta: float) -> void:
	var spr: Sprite2D = c["spr"]
	if c["white"] > 0.0:
		c["white"] -= delta
		if c["white"] <= 0.0:
			spr.material = null
	# The death clip runs on its own clock; it holds its last frame (lying).
	var anim_done: bool = true
	if c["anim"]:
		var frames: Array = c["frames"]
		c["ta"] += delta
		var fi: int = mini(int(c["ta"] * c["fps"]), frames.size() - 1)
		if fi != c["fi"]:
			c["fi"] = fi
			spr.texture = frames[fi]
		anim_done = fi >= frames.size() - 1
	var phase: int = c["phase"]
	if phase <= 1:
		c["g"] += c["vel"] * delta
		c["vh"] -= GRAVITY * delta
		c["h"] += c["vh"] * delta
		if phase == 0:
			# Spinning stops at the lying angle, it never goes past it.
			var a: float = c["ang"] + c["w"] * delta
			var lim: float = absf(c["rest_ang"])
			c["ang"] = clampf(a, -lim, lim)
		else:
			c["ang"] = lerp_angle(c["ang"], c["rest_ang"], 1.0 - exp(-LAND_EASE * delta))
		if c["h"] <= c["rest_h"] and c["vh"] < 0.0:
			c["h"] = c["rest_h"]
			_landed(c)
	elif phase == 2:
		c["ang"] = lerp_angle(c["ang"], c["rest_ang"], 1.0 - exp(-LAND_EASE * delta))
		if anim_done:
			c["t"] += delta
		if c["t"] >= c["linger"]:
			c["phase"] = 3
			c["t"] = 0.0
			if Tuning.fx_corpse_smoke_on and fx != null:
				fx.corpse_puff(c["g"])
	elif phase == 3:
		c["t"] += delta
		var fade: float = SMOKE_FADE_TIME if Tuning.fx_corpse_smoke_on else FADE_TIME
		var p: Node2D = c["pivot"]
		p.modulate.a = clampf(1.0 - c["t"] / fade, 0.0, 1.0)
		if c["t"] >= fade:
			c["phase"] = 4


func _landed(c: Dictionary) -> void:
	if c["phase"] == 0 and not c["anim"] and absf(c["vh"]) > 60.0:
		# One bounce: a little hop forward, then it lies down.
		c["vh"] = -c["vh"] * BOUNCE
		c["vel"] *= 0.5
		c["phase"] = 1
	else:
		c["phase"] = 2
		c["vel"] = Vector2.ZERO
		c["vh"] = 0.0
		c["t"] = 0.0
	if fx != null:
		fx.corpse_landed(c["g"], c["phase"] == 2)


func _place(c: Dictionary) -> void:
	var p: Node2D = c["pivot"]
	var g: Vector2 = c["g"]
	p.position = g + Vector2(0.0, -float(c["h"]))
	p.rotation = c["ang"]
	# Sorted by depth like every character; a body lying down goes under the
	# ones still standing at the same depth.
	p.z_index = Tuning.depth_z(g.y) - (2 if c["phase"] >= 2 else 1)
