extends Area2D

## Moving dummy target (SPEC PART C). Takes hits, flashes, never dies —
## F1 tests the controls, not combat.

const SIZE := Vector2(42, 58)

var origin: Vector2 = Vector2.ZERO
var amplitude: float = 140.0
var speed: float = 1.2
var phase: float = 0.0
var vertical: bool = false
var hits: int = 0

var _flash: float = 0.0


func _ready() -> void:
	origin = global_position
	collision_layer = Tuning.LAYER_TARGET
	collision_mask = 0
	monitoring = false      # bullets do the detecting
	monitorable = true
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	cs.shape = rect
	add_child(cs)


func _process(delta: float) -> void:
	phase += delta * speed
	var off: float = sin(phase) * amplitude
	global_position = origin + (Vector2(0.0, off) if vertical else Vector2(off, 0.0))
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 5.0, 0.0)
	queue_redraw()


func hit() -> void:
	hits += 1
	_flash = 1.0


func _draw() -> void:
	var base := Color(0.55, 0.30, 0.33)
	var col := base.lerp(Color(1.0, 0.95, 0.9), _flash)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), col)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), Color(0.15, 0.16, 0.2), false, 3.0)
