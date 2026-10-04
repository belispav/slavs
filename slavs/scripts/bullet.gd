extends Area2D

## Pooled projectile - never freed, only shown/hidden (CLAUDE.md rule 5).
## The same script serves the player and the enemies; only the layers differ.

## Player shots: drawn big, and their hitbox is bigger still. Generous hitboxes
## in the player's favour are design pillar 1 — a shot that looks close should
## count. Enemy shots get the opposite treatment: small, fair hitbox.
const RADIUS := 9.0
## How far past the edge of the screen a shot flies before it is recycled.
const OFF_SCREEN_MARGIN := 120.0
const HIT_RADIUS_PLAYER := 18.0
const HIT_RADIUS_HOSTILE := 6.0

var dir: Vector2 = Vector2.RIGHT
var speed: float = 0.0
var life: float = 0.0
var active: bool = false
var hostile: bool = false

var _circle: CircleShape2D


func _ready() -> void:
	collision_layer = 0
	var cs := CollisionShape2D.new()
	_circle = CircleShape2D.new()
	_circle.radius = HIT_RADIUS_PLAYER
	cs.shape = _circle
	add_child(cs)
	area_entered.connect(_on_area_entered)
	despawn()


func spawn(pos: Vector2, direction: Vector2, is_hostile: bool = false,
		shot_speed: float = 0.0) -> void:
	global_position = pos
	dir = direction
	hostile = is_hostile
	speed = shot_speed if shot_speed > 0.0 else Tuning.BULLET_SPEED
	life = Tuning.BULLET_LIFETIME
	# Player shots look for enemies and dummy targets; enemy shots for the player.
	collision_mask = Tuning.LAYER_PLAYER if hostile else Tuning.LAYER_TARGET
	_circle.radius = HIT_RADIUS_HOSTILE if hostile else HIT_RADIUS_PLAYER
	active = true
	show()
	set_physics_process(true)
	set_deferred("monitoring", true)
	# BEZ TOHTO sa strela kresli podla stareho smeru a starej strany:
	# Godot si drzi zoznam kresliacich prikazov a show() ho neobnovi.
	queue_redraw()


func despawn() -> void:
	active = false
	hide()
	set_physics_process(false)
	set_deferred("monitoring", false)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	# Same depth rule as the bodies. Without it a shot drew either always over
	# or always under every character, depending on nothing meaningful.
	z_index = Tuning.depth_z(global_position.y)

	# Shots end when they leave the screen, not on a stopwatch. A fixed lifetime
	# is a distance in disguise, and it depended on the projectile's speed: the
	# slow enemy shot covered 363 units of a 1600 unit screen before vanishing
	# in mid-air, a quarter of the way to anything.
	if _off_screen():
		despawn()
		return

	# The timer stays as a safety net only, long enough never to be reached in
	# normal play. Without it a shot fired at a camera that then stops moving
	# could sit in the pool forever.
	life -= delta
	if life <= 0.0:
		despawn()


func _off_screen() -> bool:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var at: Vector2 = get_global_transform_with_canvas().origin
	return at.x < -OFF_SCREEN_MARGIN or at.x > view.x + OFF_SCREEN_MARGIN \
		or at.y < -OFF_SCREEN_MARGIN or at.y > view.y + OFF_SCREEN_MARGIN


## Both directions go through the same Area signal now. Enemy shots used to
## check body_entered against the player's plain movement CollisionShape2D
## (the F1 grey box's size, 30x54, never resized to the drawn art), so a shot
## through the upper half of the body - above that small box - silently
## missed. The player now exposes its own fitted `_hurtbox` Area the same way
## every enemy already does, so both cases are "which Area did I hit".
func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	var method := "take_damage" if hostile else "hit"
	# The hurtbox may be a child of the thing that actually takes damage.
	var victim: Node = area
	if not victim.has_method(method) and area.get_parent() != null:
		victim = area.get_parent()
	if not victim.has_method(method):
		return
	if hostile:
		victim.call(method, 1, global_position)
	elif victim.has_method("hit_from"):
		victim.call("hit_from", dir)
	else:
		victim.call(method)
	despawn()


func _draw() -> void:
	# What is drawn solid is what hits. The enemy shot used to be a 52 unit
	# streak with a 7 unit head over a hitbox of 6 - a bright bar could pass
	# straight through the player and do nothing, which reads as broken just as
	# badly as being hit by nothing.
	#
	# Everything beyond the hit radius is now transparent: a tail and a glow,
	# clearly not the object itself.
	if hostile:
		var tail: Vector2 = -dir * 30.0
		draw_line(tail, Vector2.ZERO, Color(1.0, 0.45, 0.32, 0.30), 5.0)
		draw_circle(Vector2.ZERO, HIT_RADIUS_HOSTILE + 3.0,
			Color(0.10, 0.05, 0.08, 0.55))
		draw_circle(Vector2.ZERO, HIT_RADIUS_HOSTILE, Color(1.0, 0.42, 0.30))
		draw_circle(Vector2.ZERO, HIT_RADIUS_HOSTILE * 0.5,
			Color(1.0, 0.95, 0.85))
	else:
		draw_line(-dir * 16.0, Vector2.ZERO, Color(1.0, 0.85, 0.4, 0.35), 6.0)
		draw_circle(Vector2.ZERO, HIT_RADIUS_PLAYER, Color(1.0, 0.75, 0.25, 0.28))
		draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.90, 0.45))
		draw_circle(Vector2.ZERO, RADIUS * 0.45, Color(1.0, 1.0, 0.9))
