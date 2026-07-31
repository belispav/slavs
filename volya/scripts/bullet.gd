extends Area2D

## Pooled projectile - never freed, only shown/hidden (CLAUDE.md rule 5).
## The same script serves the player and the enemies; only the layers differ.

## Player shots: drawn big, and their hitbox is bigger still. Generous hitboxes
## in the player's favour are design pillar 1 — a shot that looks close should
## count. Enemy shots get the opposite treatment: small, fair hitbox.
const RADIUS := 9.0
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
	body_entered.connect(_on_body_entered)
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


func despawn() -> void:
	active = false
	hide()
	set_physics_process(false)
	set_deferred("monitoring", false)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		despawn()


func _on_area_entered(area: Area2D) -> void:
	if not active or hostile:
		return
	# The hurtbox may be a child of the thing that actually takes damage.
	var victim: Node = area
	if not victim.has_method("hit") and area.get_parent() != null:
		victim = area.get_parent()
	if victim.has_method("hit"):
		victim.call("hit")
		despawn()


func _on_body_entered(body: Node) -> void:
	if not active or not hostile:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", 1, global_position)
		despawn()


func _draw() -> void:
	if hostile:
		# clearly readable, but visibly a thin spear you can slip past
		draw_line(-dir * 16.0, dir * 16.0, Color(0.98, 0.45, 0.38), 5.0)
		draw_circle(dir * 16.0, 4.0, Color(1.0, 0.8, 0.7))
	else:
		draw_circle(Vector2.ZERO, RADIUS * 1.6, Color(1.0, 0.75, 0.25, 0.30))
		draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.90, 0.45))
		draw_circle(Vector2.ZERO, RADIUS * 0.45, Color(1.0, 1.0, 0.9))
		draw_line(-dir * 14.0, Vector2.ZERO, Color(1.0, 0.85, 0.4, 0.45), 6.0)
