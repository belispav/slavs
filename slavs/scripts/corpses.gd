extends Node2D

## Package 2 "Smrt nepriatela" - A9 (death with a punchline) and T36 (how the
## body disappears).
##
## A killed enemy goes back to the pool at once (enemy.gd despawn), so what the
## player sees falling is NOT the enemy: it is a separate picture.
##   - With a death clip (the rusher: PixelLab "falling-back-death"): the clip
##     plays at corpse_anim_fps while the body hops a little along the blow and
##     slides, then the last frame (lying) stays.
##   - Without a clip (gunman, brute): the frame the enemy died in is thrown
##     along the blow, spins onto its back, bounces once and lies.
## Then it vanishes (puff of smoke, or a fade).
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

var fx   # fx.gd - landing blood, smoke puff

var _live: Array = []     # active corpses (Dictionary each)
var _spare: Array = []    # pivots ready for reuse


func setup(fx_node) -> void:
	fx = fx_node


## `tex` the frame the enemy died in, `flip` its flip_h, `art_scale` the
## sprite scale, `off` the sprite position relative to the FEET, `body_h` the
## drawn height, `dir` the way the blow travelled (zero = unknown, `side` is
## then +1/-1 away from the hero), `frames` the enemy's death clip (may be empty).
func spawn(tex: Texture2D, flip: bool, art_scale: Vector2, off: Vector2,
		feet: Vector2, body_h: float, dir: Vector2, side: float, frames: Array) -> void:
	if not Tuning.fx_corpse_on or tex == null:
		return
	if _live.size() >= MAX_CORPSES:
		_release(0)
	var sx: float = signf(dir.x) if absf(dir.x) > 0.2 else side
	if sx == 0.0:
		sx = 1.0
	var power: float = Tuning.corpse_power
	var anim: bool = frames.size() > 1
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
		spr.flip_h = sx < 0.0
		spr.position = Vector2(0.0, off.y)
	else:
		spr.texture = tex
		spr.flip_h = flip
		# Rotation pivot = middle of the body, so it spins like a body.
		spr.position = off + Vector2(0.0, body_h * 0.5)
	var c := {
		"pivot": pivot, "spr": spr,
		"g": feet,
		"vel": Vector2(sx * FLY_SPEED * power * randf_range(0.8, 1.2),
			dir.y * FLY_SPEED * 0.4 * power),
		"h": 0.0 if anim else body_h * 0.5,
		"vh": FLY_UP * power * randf_range(0.8, 1.2),
		"rest_h": 0.0 if anim else body_h * 0.2,
		"ang": 0.0,
		"w": 0.0 if anim else -sx * randf_range(SPIN_MIN, SPIN_MAX) * clampf(power, 0.4, 1.5),
		"rest_ang": 0.0 if anim else -sx * (PI * 0.5 + randf_range(-0.12, 0.12)),
		"phase": 0,        # 0 flying, 1 after the bounce, 2 lying, 3 vanishing
		"t": 0.0,
		"anim": anim, "frames": frames, "ta": 0.0, "fi": 0,
		"white": Tuning.hit_white_ms / 1000.0 if Tuning.fx_white_on else 0.0,
	}
	if c["white"] > 0.0:
		spr.material = ENEMY_SCRIPT._get_white_material()
	_live.append(c)
	_place(c)


func _release(i: int) -> void:
	var c: Dictionary = _live[i]
	var pivot: Node2D = c["pivot"]
	pivot.hide()
	_spare.append(pivot)
	_live.remove_at(i)


func clear() -> void:
	while not _live.is_empty():
		_release(_live.size() - 1)


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
		var fi: int = mini(int(c["ta"] * Tuning.corpse_anim_fps), frames.size() - 1)
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
		if c["t"] >= Tuning.corpse_linger:
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
