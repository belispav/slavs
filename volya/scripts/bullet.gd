extends Area2D

## Pooled bullet — never freed, only shown/hidden (CLAUDE.md rule 5).

const RADIUS := 5.0

var dir: Vector2 = Vector2.RIGHT
var life: float = 0.0
var active: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = Tuning.LAYER_TARGET
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	cs.shape = circle
	add_child(cs)
	area_entered.connect(_on_area_entered)
	despawn()


func spawn(pos: Vector2, direction: Vector2) -> void:
	global_position = pos
	dir = direction
	life = Tuning.BULLET_LIFETIME
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
	global_position += dir * Tuning.BULLET_SPEED * delta
	life -= delta
	if life <= 0.0:
		despawn()


func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	if area.has_method("hit"):
		area.call("hit")
	despawn()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.90, 0.45))
	draw_circle(Vector2.ZERO, RADIUS * 0.5, Color(1.0, 1.0, 0.85))
