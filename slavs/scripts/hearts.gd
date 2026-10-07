extends Node2D

## Hit points as hearts above a character's head (Pavel 2026-10-07).
##
## A full heart is red with a dark outline; a lost one keeps only a black
## outline. Drawn in code as little pixel hearts (2 px per cell) so it matches
## the pixel art. More than ROW_MAX hearts wrap into a second row upward (the
## brute has 10). Own absolute z, above every character (character z is its
## world Y, never above ~4000).
##
## Redraws only when hp / max_hp change. Visibility follows the panel switch
## Tuning.hearts_mode: 0 = off, 1 = the hero and wounded enemies only,
## 2 = everybody. `is_hero` marks the hero's own hearts (shown in mode 1).

const CELL: int = 2
const ROW_MAX: int = 5
const GAP: int = 2
## 7 x 6 heart. X = filled.
const SHAPE: Array[String] = [
	".XX.XX.",
	"XXXXXXX",
	"XXXXXXX",
	".XXXXX.",
	"..XXX..",
	"...X...",
]
const FULL_FILL: Color = Color(0.86, 0.12, 0.14)
const FULL_EDGE: Color = Color(0.30, 0.02, 0.04)
const LOST_EDGE: Color = Color(0.0, 0.0, 0.0)

var is_hero: bool = false
var _hp: int = -1
var _max: int = -1


func _ready() -> void:
	z_as_relative = false
	z_index = 3900
	_apply_visibility()


func _process(_delta: float) -> void:
	_apply_visibility()


## Where the hearts sit: `head` = the top of the drawn head in the parent's
## coordinates (the hearts are drawn above that point).
func place(head: Vector2) -> void:
	position = head


func set_state(hp: int, max_hp: int) -> void:
	if hp == _hp and max_hp == _max:
		return
	_hp = hp
	_max = max_hp
	queue_redraw()
	_apply_visibility()


func _apply_visibility() -> void:
	var m: int = Tuning.hearts_mode
	var show_it: bool = m >= 2 or (m == 1 and (is_hero or _hp < _max))
	if _hp <= 0:
		show_it = false
	if visible != show_it:
		visible = show_it


func _cell_is_edge(x: int, y: int) -> bool:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = x + d.x
		var ny: int = y + d.y
		if nx < 0 or ny < 0 or ny >= SHAPE.size() or nx >= SHAPE[0].length():
			return true
		if SHAPE[ny][nx] != "X":
			return true
	return false


func _draw() -> void:
	if _max <= 0:
		return
	var hw: int = SHAPE[0].length() * CELL
	var hh: int = SHAPE.size() * CELL
	var pitch: int = hw + GAP
	for i in _max:
		var row: int = i / ROW_MAX
		var col: int = i % ROW_MAX
		var in_row: int = mini(ROW_MAX, _max - row * ROW_MAX)
		var x0: int = int(-in_row * pitch * 0.5 + GAP * 0.5) + col * pitch
		var y0: int = -hh - row * (hh + GAP)
		var full: bool = i < _hp
		for y in SHAPE.size():
			for x in SHAPE[y].length():
				if SHAPE[y][x] != "X":
					continue
				var edge: bool = _cell_is_edge(x, y)
				var c: Color
				if full:
					c = FULL_EDGE if edge else FULL_FILL
				elif edge:
					c = LOST_EDGE
				else:
					continue
				draw_rect(Rect2(x0 + x * CELL, y0 + y * CELL, CELL, CELL), c)
