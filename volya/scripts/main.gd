extends Node2D

## F1 test scene, built entirely in code (SPEC PART C):
## flat ground + 3 platforms + moving dummy targets. Grey boxes, no art.

const GROUND_Y := 600.0
const LEVEL_LEFT := 0.0
const LEVEL_RIGHT := 2400.0

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

func _build_level() -> void:
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
	player.set_camera_limits(LEVEL_LEFT - 80.0, LEVEL_RIGHT + 80.0, -500.0, GROUND_Y + 200.0)
	player.fire_requested.connect(_on_fire_requested)
	player.died.connect(_restart)


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
	free_enemy.spawn(Vector2(x, GROUND_Y - 120.0), kind, player)


func _on_enemy_died(_at: Vector2) -> void:
	kills += 1


func _on_enemy_throw(from: Vector2, dir: Vector2) -> void:
	_fire(from, dir, true, Tuning.THROWER_SHOT_SPEED)


func _restart() -> void:
	deaths += 1
	for e in enemies:
		if e.active:
			e.despawn()
	for b in bullets:
		if b.active:
			b.despawn()
	_spawn_cd = 1.2
	player.respawn()


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
