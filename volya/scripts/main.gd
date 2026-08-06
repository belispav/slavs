extends Node2D

## F1 test scene, built entirely in code (SPEC PART C):
## flat ground + 3 platforms + moving dummy targets. Grey boxes, no art.

const GROUND_Y := 600.0
const LEVEL_LEFT := 0.0
## The background repeats on the GPU, so length costs nothing to draw. 2400 was
## barely more than a screen and a half - not enough to tell whether scrolling
## along feels like travelling anywhere.
const LEVEL_RIGHT := 12000.0

## Leftover F1 shooting-range targets. Off now that there are real enemies to
## shoot at; they were only ever there to give aiming something to track.
const SHOW_AIM_TARGETS := false

## How far above the ground the walkable field reaches, as a multiple of the
## screen height.
##
## The bottom is fixed - that is where the ground, the wall, the river will be
## drawn - and everything above it is playable. At 1.5 the camera has to travel
## upwards, which is the point: a band shorter than the screen is exhausted in a
## second by a character 130 units tall, and there is nowhere to put the feet of
## an enemy or the bottom of a cage.
##
const BACKGROUND_PATH := "res://art/env_02.png"

## Which rows of the background picture are open ground, measured from the art
## itself. Above them is the palisade and the props stacked against it, below
## them the rocks and the river.
##
## The playable field is taken from these, not the other way round. Deciding the
## field in screen fractions and then hoping the picture agreed was what made
## the earlier attempts feel wrong - the character could walk into the river.
## Rows of env_02 the character's FEET may stand on: the open grass, all of it.
##
## Measured: palisade ends around row 600, grass runs to about 1240, water from
## about 1252.
##
## Earlier versions cut the band down to leave room on screen for the palisade
## above and the river below at the same time. That cannot work here - the grass
## alone is 640 rows against a 720 row screen, so both boundaries and the
## character's head have to share 80 rows, and all three come out as slivers.
##
## They do not have to be on screen at the same time. The camera follows the
## character up and down, so walking to the back of the field brings the
## palisade into view and walking to the water brings the water. Each boundary
## is seen when it matters, at full height, and the whole grass stays playable.
const BG_WALK_TOP := 600.0
const BG_WALK_BOTTOM := 1240.0

var player            # untyped on purpose: the script is attached at runtime
var bullets: Array = []
var enemies: Array = []
var _bullet_next: int = 0
var _spawn_cd: float = 0.0

var kills: int = 0
var deaths: int = 0
var hud: Label
var _alive: int = 0


func _ready() -> void:
	_build_level()
	_build_player()
	# The moving targets are F1 shooting-range furniture, not content. They
	# exist to give the aim something to track while the controls are tuned,
	# and they only get in the way once there are real enemies.
	if SHOW_AIM_TARGETS:
		_build_targets()
	_build_bullet_pool()
	_build_enemy_pool()
	_build_hud()
	var overlay_script: GDScript = load("res://scripts/debug_overlay.gd")
	add_child(overlay_script.new())


func _process(delta: float) -> void:
	if player.global_position.y > Tuning.RESPAWN_Y:
		_restart()
	_alive = _count_alive()      # spocitane RAZ za snimku, nie trikrat
	_spawn_tick(delta)
	_update_hud()


# ---------------------------------------------------------------- level ---

## Playable height, in world units: the open ground in the picture.
func field_height() -> float:
	return BG_WALK_BOTTOM - BG_WALK_TOP


## World y of the background picture's top row. Placed so its open ground ends
## on GROUND_Y, which everything else is already measured from.
func background_top() -> float:
	return GROUND_Y - BG_WALK_BOTTOM


func background_height() -> float:
	var texture: Texture2D = load(BACKGROUND_PATH) as Texture2D
	return float(texture.get_height()) if texture != null else 1536.0


## The background, repeated sideways for the length of the level.
##
## One Sprite2D with a region wider than the texture and repeat turned on: the
## GPU does the tiling, so a level ten screens long costs the same as one. The
## picture's edges match to within a few shades, which is what makes this
## possible at all.
func _build_background() -> void:
	var texture: Texture2D = load(BACKGROUND_PATH) as Texture2D
	if texture == null:
		push_warning("Pozadie %s sa nenacitalo." % BACKGROUND_PATH)
		return

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	# Wider than the level on both sides, so the edges are never reached.
	var span: float = (LEVEL_RIGHT - LEVEL_LEFT) + texture.get_width() * 2.0
	sprite.region_rect = Rect2(0.0, 0.0, span, texture.get_height())
	sprite.position = Vector2(LEVEL_LEFT - texture.get_width(), background_top())
	sprite.z_index = -100
	add_child(sprite)


func _build_level() -> void:
	if Touch.config.free_movement:
		# No floor and no ceiling. There is no gravity to hold the character
		# down and no jump to carry it up, so the edges of the field are limits
		# on where it may walk - and a grey box drawn across the background is
		# the last thing wanted now that there is a background.
		#
		# Platforms are not built either: without a jump they are unreachable
		# scenery standing in the way.
		_build_background()
		return

	_solid(Vector2(1200, GROUND_Y + 100.0), Vector2(2560, 200), Color(0.20, 0.22, 0.27))
	_solid(Vector2(LEVEL_LEFT - 40.0, GROUND_Y - 300.0), Vector2(80, 800), Color(0.20, 0.22, 0.27))
	_solid(Vector2(LEVEL_RIGHT + 40.0, GROUND_Y - 300.0), Vector2(80, 800), Color(0.20, 0.22, 0.27))

	# 3 one-way platforms — jump-through, land-on (Metal Slug style)
	_platform(Vector2(430, 460), Vector2(280, 24))
	_platform(Vector2(880, 330), Vector2(260, 24))
	_platform(Vector2(1350, 460), Vector2(300, 24))


func _solid(pos: Vector2, size: Vector2, col: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = Tuning.LAYER_WORLD
	body.collision_mask = 0
	add_child(body)

	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	body.add_child(cs)

	var vis := ColorRect.new()
	vis.color = col
	vis.position = -size * 0.5
	vis.size = size
	vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(vis)
	return body


func _platform(pos: Vector2, size: Vector2) -> void:
	var body := _solid(pos, size, Color(0.33, 0.36, 0.43))
	var cs := body.get_child(0) as CollisionShape2D
	cs.one_way_collision = true
	cs.one_way_collision_margin = 8.0


# --------------------------------------------------------------- actors ---

func _build_player() -> void:
	player = CharacterBody2D.new()
	player.set_script(load("res://scripts/player.gd"))
	add_child(player)
	player.global_position = Vector2(240, GROUND_Y - 120.0)
	player.spawn_point = player.global_position
	# The field is stated in terms of where the feet may stand. The player turns
	# that into a limit on its own origin, which sits half a body higher.
	player.set_foot_field(GROUND_Y - field_height(), GROUND_Y,
		LEVEL_LEFT + 40.0, LEVEL_RIGHT - 40.0)

	if Touch.config.free_movement:
		# The camera follows the character up and down, stopping at the edges
		# of the picture. That is what lets the field use the whole grass while
		# the palisade and the river are still seen at full height - each comes
		# into view as the character walks towards it.
		player.set_camera_limits(LEVEL_LEFT - 80.0, LEVEL_RIGHT + 80.0,
			background_top(), background_top() + background_height())
	else:
		player.set_camera_limits(LEVEL_LEFT - 80.0, LEVEL_RIGHT + 80.0,
			player.field_top - 260.0, GROUND_Y + 200.0)
	player.fire_requested.connect(_on_fire_requested)
	player.died.connect(_on_player_died)


func _build_targets() -> void:
	_target(Vector2(700, GROUND_Y - 40.0), 180.0, 1.1, false)
	_target(Vector2(880, 250.0), 90.0, 1.7, true)
	_target(Vector2(1350, GROUND_Y - 40.0), 240.0, 0.8, false)
	_target(Vector2(1900, GROUND_Y - 40.0), 120.0, 1.4, false)


func _target(pos: Vector2, amplitude: float, speed: float, vertical: bool) -> void:
	var t = Area2D.new()
	t.set_script(load("res://scripts/target.gd"))
	add_child(t)
	t.global_position = pos
	t.origin = pos
	t.amplitude = amplitude
	t.speed = speed
	t.vertical = vertical


func _build_bullet_pool() -> void:
	var holder := Node2D.new()
	holder.name = "Bullets"
	add_child(holder)
	var bullet_script: GDScript = load("res://scripts/bullet.gd")
	for i in Tuning.BULLET_POOL_SIZE:
		var b := Area2D.new()
		b.set_script(bullet_script)
		holder.add_child(b)
		bullets.append(b)


func _build_enemy_pool() -> void:
	var holder := Node2D.new()
	holder.name = "Enemies"
	add_child(holder)
	var enemy_script: GDScript = load("res://scripts/enemy.gd")
	for i in Tuning.ENEMY_POOL_SIZE:
		var e = CharacterBody2D.new()
		e.set_script(enemy_script)
		holder.add_child(e)
		e.died.connect(_on_enemy_died)
		e.throw_requested.connect(_on_enemy_throw)
		enemies.append(e)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(20, 640)
	# Goes away with the rest of the tuning readouts when the panel is collapsed.
	hud.add_to_group("debug_ui")
	layer.add_child(hud)


# --------------------------------------------------------------- spawning ---

func _count_alive() -> int:
	var n: int = 0
	for e in enemies:
		if e.active:
			n += 1
	return n


func _spawn_tick(delta: float) -> void:
	_spawn_cd -= delta
	if _spawn_cd > 0.0:
		return
	_spawn_cd = Tuning.SPAWN_INTERVAL
	if _alive >= Tuning.ENEMY_MAX_ALIVE:
		return

	var free_enemy = null
	for e in enemies:
		if not e.active:
			free_enemy = e
			break
	if free_enemy == null:
		return

	# ALWAYS from the right, never from the left.
	# The left thumb physically covers the left of the screen, so a threat
	# arriving there is invisible and therefore unfair. The control scheme
	# dictates the level design, not the other way round.
	var x: float = clampf(
		player.global_position.x + 640.0 + Tuning.SPAWN_MARGIN
			+ randf() * Tuning.SPAWN_JITTER,
		LEVEL_LEFT + 60.0, LEVEL_RIGHT - 60.0)
	var kind: int = 1 if randf() < Tuning.THROWER_RATIO else 0

	# In free movement there is no floor to walk in on, so they arrive spread
	# across the depth of the field. Dropping them all on one line would make
	# the second axis pointless: nothing would ever need dodging sideways.
	var y: float = GROUND_Y - 120.0
	if Touch.config.free_movement:
		# Anywhere across the open ground. The whole field is on screen, so
		# there is no part of it an enemy could arrive in unseen.
		y = randf_range(GROUND_Y - field_height() + 30.0, GROUND_Y - 30.0)

	free_enemy.spawn(Vector2(x, y), kind, player)


func _on_enemy_died(_at: Vector2) -> void:
	kills += 1


func _on_enemy_throw(from: Vector2, dir: Vector2) -> void:
	_fire(from, dir, true, Tuning.THROWER_SHOT_SPEED)


## Death clears the field and gives the player a moment, but leaves them where
## they were. Being sent back to the start every time made it impossible to
## settle into a run.
func _on_player_died() -> void:
	deaths += 1
	_clear_field()
	_spawn_cd = 1.2
	player.revive()


## Falling out of the world is the one case where staying put is not possible.
func _restart() -> void:
	deaths += 1
	_clear_field()
	_spawn_cd = 1.2
	player.respawn()


func _clear_field() -> void:
	for e in enemies:
		if e.active:
			e.despawn()
	for b in bullets:
		if b.active:
			b.despawn()


func _update_hud() -> void:
	hud.text = "ZIVOTY %d/%d    ZABITI %d    NA SCENE %d    SMRTI %d" % [
		player.hp, Tuning.PLAYER_MAX_HP, kills, _alive, deaths]


# --------------------------------------------------------------- shooting ---

func _on_fire_requested(from: Vector2, dir: Vector2) -> void:
	_fire(from, dir, false, 0.0)


func _fire(from: Vector2, dir: Vector2, hostile: bool, shot_speed: float) -> void:
	for i in bullets.size():
		var idx: int = (_bullet_next + i) % bullets.size()
		var b = bullets[idx]
		if not b.active:
			b.spawn(from, dir, hostile, shot_speed)
			_bullet_next = (idx + 1) % bullets.size()
			return
