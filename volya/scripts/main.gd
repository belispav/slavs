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
## CHOSEN 2026-08-13 by Pavel, on device: "nove pozadie je super, ovela lepsie
## ako to predtym, takto to chceme nechat."
##
## Generated with the style token in ref/PROMPTY.md pushed away from "16 bit"
## (which is what made the old generator draw 2-3 px blocks) and towards fine
## grain. Measured on the walkable band: 39.1 % neighbour difference against
## env_03's 4.8 %. Same 2816x1536 canvas and near-identical layout, so it went
## in as a drop-in - palisade ends ~530, river starts ~1215, against
## BG_WALK_TOP/BOTTOM's 560/1210.
## env_05, generated 2026-08-14 with the prompt pushed further towards fine
## grain (single-pixel stippling, heavy dithering, no flat areas). Measured on
## the walkable band: 65.9 % neighbour difference, against env_04's 39.1 % and
## env_03's 4.8 %.
##
## The reason it also WON on contrast, not just detail: band luma 103.7 against
## env_04's 80.0, which was sitting exactly on the >= 80 rule with no margin.
##
## Drop-in confirmed by drawing it (METHOD rule 3b), not by arithmetic: the hero
## standing with his feet on BG_WALK_TOP is in grass under the palisade, and on
## BG_WALK_BOTTOM he is at the water's edge. Both limits still land where they
## mean something, so 560/1210 are unchanged.
##
## It arrived as a JPEG and was converted once to PNG. JPEG rings every hard
## pixel edge; the loss already baked in stays, but nothing more is added.
## Ask for PNG next time.
const BACKGROUND_PATH := "res://art/env_05.png"
## The one it replaced, kept on a panel switch. Not a fallback - a reference, so
## a new background is judged against the last one instead of against a memory
## of it.
const BACKGROUND_ALT_PATH := "res://art/env_04.png"

## Which rows of the background picture are open ground, measured from the art
## itself. Above them is the palisade and the props stacked against it, below
## them the rocks and the river.
##
## The playable field is taken from these, not the other way round. Deciding the
## field in screen fractions and then hoping the picture agreed was what made
## the earlier attempts feel wrong - the character could walk into the river.
## Rows of env_02 the character's FEET may stand on: the open grass, all of it.
##
## Measured on env_03: palisade ends around row 560, grass runs to about 1210,
## the bank and the water from there down.
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
const BG_WALK_TOP := 560.0
const BG_WALK_BOTTOM := 1210.0

var player            # untyped on purpose: the script is attached at runtime
var bullets: Array = []
var enemies: Array = []
var _bullet_next: int = 0
var _spawn_cd: float = 0.0

var kills: int = 0
var deaths: int = 0
var hud: Label
var _alive: int = 0
## Kept so the debug panel can flip its filter live. See _apply_bg_filter().
var _bg_sprite: Sprite2D
var _bg_smooth_applied: bool = false
var _bg_alt_applied: bool = false
## Parallax2D nodes built from BG_LAYERS entries with factor > 1.0 (nearer
## than the ground - currently just env_05_fg.png). Kept so the "rychlost
## popredia" panel slider can drive their speed live. See
## _apply_fg_parallax_speed().
var _fg_parallax_layers: Array = []


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
	_apply_bg_filter()
	_apply_fg_parallax_speed()
	_separate_enemies()


## Follows the "rychlost popredia" panel slider (Tuning.fg_parallax_factor)
## so the foreground strip's speed can be found on the device - KROK 2, tried
## 1.15 / 1.3 / 1.5 and picked by Pavel - without a redeploy per try.
func _apply_fg_parallax_speed() -> void:
	for layer in _fg_parallax_layers:
		layer.scroll_scale.x = Tuning.fg_parallax_factor


## Push overlapping enemies apart.
##
## Rushers all head for the same point - the player - so they arrive as a single
## pile of bodies drawn on top of each other. Reported by Pavel 2026-08-13:
## "runneri ... skoncia na jednej kope a vyzera to dost cudne."
##
## Done here rather than in enemy.gd because main.gd already holds the pool.
## An enemy asking the scene tree for its neighbours every frame would be 34
## group lookups per frame instead of one pass, which is real time on a 150 EUR
## phone - and the frame budget is what the controls feel like.
##
## Positions are nudged rather than velocities pushed: a force fights the
## approach logic and turns into orbiting, while a nudge just stops two bodies
## occupying one spot and leaves the AI alone.
func _separate_enemies() -> void:
	var min_gap: float = Tuning.enemy_separation
	if min_gap <= 0.0:
		return
	var live: Array = []
	for e in enemies:
		if e.active:
			live.append(e)

	for i in range(live.size()):
		for j in range(i + 1, live.size()):
			var a = live[i]
			var b = live[j]
			var away: Vector2 = a.global_position - b.global_position
			# Depth counts for less than sideways distance: the field is only
			# 1.5 screens tall and shoving enemies apart vertically walks them
			# out of the playable band.
			away.y *= 2.0
			var d: float = away.length()
			if d >= min_gap:
				continue
			if d < 0.001:
				# Exactly on top of each other - pick a direction rather than
				# dividing by zero and sending both to infinity.
				away = Vector2(randf() - 0.5, randf() - 0.5).normalized()
				d = 0.001
			var push: Vector2 = away / d * (min_gap - d) * 0.5
			push.y *= 0.5
			a.global_position += push
			b.global_position -= push


## Follow the debug panel's background switches. Only touches the sprite when a
## value actually changed, so this costs two bool compares per frame.
##
## The filter switch is kept even though it was measured to do almost nothing
## (0.36 % on env_03 - the blockiness is painted in, not sampled in). It is a
## measuring aid for every future background, not a fix.
func _apply_bg_filter() -> void:
	if _bg_sprite == null:
		return
	if Debug.smooth_background != _bg_smooth_applied:
		_bg_smooth_applied = Debug.smooth_background
		# No mipmaps: the background is MAGNIFIED (1 asset px per world unit
		# against the device's ~1.5), and mipmaps only do anything when
		# minifying.
		_bg_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR \
			if _bg_smooth_applied else CanvasItem.TEXTURE_FILTER_NEAREST
	if Debug.alt_background != _bg_alt_applied:
		_bg_alt_applied = Debug.alt_background
		var path: String = BACKGROUND_ALT_PATH if _bg_alt_applied else BACKGROUND_PATH
		var texture: Texture2D = load(path) as Texture2D
		if texture != null:
			_bg_sprite.texture = texture


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
	_bg_sprite = sprite


## Parallax layers in front of or behind the ground, as DATA - see
## DIZAJN_pozadie_a_rozlisenie.md §8, KROK 1. Adding a layer should be one line
## here, not a code change.
##
## The ground is deliberately NOT an entry here and never will be: it is drawn
## by _build_background() above, at parallax factor 1.0 by construction,
## because it never passes through Parallax2D at all (hard constraint §9.1).
## A layer at any other factor scrolls at a different rate than the ground -
## grass would slide under the character's feet, and BG_WALK_TOP/BOTTOM would
## stop lining up with what the picture shows.
##
## Fields per entry:
##   path:        res:// path to the layer's texture.
##   factor:      horizontal parallax_scale. < 1.0 = further than the ground
##                (moves slower, reads as distant); > 1.0 = nearer than the
##                ground (moves faster; only the one foreground strip in
##                KROK 2 is meant to use this).
##   asset_scale: the layer's own S if it differs from the ground's S = 1
##                (KROK 3's softer, lower-resolution distant layers).
##   y:           offset from background_top() - the same coordinate space
##                _build_background() uses - so a layer can be pinned to a
##                row of the ground picture.
##
## Empty array = _build_parallax_layers() below adds nothing = the game looks
## exactly as it did before this const existed. That is KROK 1's checkpoint.
## Empty again as of 2026-08-15: env_05_fg.png (KROK 2's foreground strip
## attempt) is pulled. Not because a foreground layer is a bad idea - because
## that specific file measured broken (43.4 % partially-transparent pixels
## where pixel art wants 0 %, 40 % darker than the ground it sits in front
## of, and 350 px tall against a 720-unit screen). File is kept on disk,
## just out of this array and off the debug panel. Root cause and the
## corrected requirements (hard alpha, 120-150 px, brightness >= ground) are
## in DIZAJN_pozadie_a_rozlisenie.md SS8. Order also changed: the top band
## (sky/forest/hills/distant palisade - layers BEHIND the player) comes
## before the foreground strip now, per Pavel.
##
## "factor" per entry is only the value a Parallax2D is BUILT with (kept as a
## literal rather than a cross-script const reference - GDScript const
## initialisers must be foldable at parse time and an autoload const is not
## a safe bet there). If a factor > 1 (foreground) entry exists, the panel
## slider overwrites it live every frame from Tuning.fg_parallax_factor (see
## _apply_fg_parallax_speed()), so the literal here is only frame-0's start.
const BG_LAYERS := [
]


## Builds every entry in BG_LAYERS as its own Parallax2D, called right after
## _build_background() so the ground is always in the tree first and every
## parallax layer stacks around it.
##
## Vertical scroll_scale is hardcoded to 1.0 on every layer here - correct
## for layers BEHIND the player (factor < 1), which must land on
## BG_WALK_TOP/BOTTOM as the camera travels vertically; a different vertical
## rate would drift them out of registration with the walkable field. A
## layer in FRONT of the player (factor > 1) does not have to hit any line
## in the picture, so this does not bind it - see
## DIZAJN_pozadie_a_rozlisenie.md §9.2. env_05_fg.png ran 1.3 horizontal
## against this hardcoded 1.0 vertical, which was never a deliberate choice,
## just what this function does unconditionally; worth revisiting once a
## foreground layer returns.
##
## z_index: FIXED 2026-08-15, was inverted since KROK 1 and only just found
## while adding the first real "behind" layer. The ground sprite (z = -100)
## is ONE OPAQUE image covering its whole rectangle top to bottom - it has no
## transparency anywhere. z_index < -100 draws BEFORE (behind) the ground, so
## anything put there is entirely hidden behind it; the camera is also
## clamped to background_top()..background_top()+background_height() (see
## _build_player()), so there is no world space above the picture to escape
## into either. A "further away" layer therefore has to draw IN FRONT OF the
## ground (z > -100) to be seen at all - it visually overpaints whatever
## env_05 already has in that same picture region, at its own (slower)
## scroll speed, rather than sitting further back in the z-buffer sense.
## Layers with factor < 1 now get -99 and up, one step closer per entry in
## array order (furthest-first, per the doc's §5 table) - still comfortably
## behind the player and enemies, whose z_index (Tuning.depth_z) tracks
## their own world Y and never goes anywhere near this range in the
## walkable band. The one factor > 1 layer (foreground) keeps +50, ahead of
## the player.
func _build_parallax_layers() -> void:
	var behind_count: int = 0
	for entry in BG_LAYERS:
		var texture: Texture2D = load(entry["path"]) as Texture2D
		if texture == null:
			push_warning("Parallax vrstva %s sa nenacitala." % str(entry["path"]))
			continue

		var factor: float = entry["factor"]
		var asset_scale: float = entry.get("asset_scale", 1.0)
		var y_offset: float = entry.get("y", 0.0)

		var layer := Parallax2D.new()
		layer.scroll_scale = Vector2(factor, 1.0)
		layer.repeat_size = Vector2(texture.get_width() / asset_scale, 0.0)
		layer.repeat_times = 8
		if factor < 1.0:
			layer.z_index = -99 + behind_count
			behind_count += 1
		else:
			layer.z_index = 50
			_fg_parallax_layers.append(layer)
		add_child(layer)

		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.scale = Vector2.ONE / asset_scale
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position.y = background_top() + y_offset
		layer.add_child(sprite)


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
		_build_parallax_layers()
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
		e.melee_hit.connect(_on_enemy_melee_hit)
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


## Same as _count_alive, but only one kind - for the debug density caps.
## Not folded into the per-frame _alive count above: the spawner is the only
## thing that needs this, and it already runs throttled by SPAWN_INTERVAL,
## not every frame.
func _count_alive_kind(kind: int) -> int:
	var n: int = 0
	for e in enemies:
		if e.active and e.kind == kind:
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
	# Debug panel switches. Force to the other kind if only one is off; if
	# both are off there is nothing left to spawn this tick.
	if kind == 0 and Debug.disable_rusher:
		kind = 1
	elif kind == 1 and Debug.disable_thrower:
		kind = 0
	if (kind == 0 and Debug.disable_rusher) or (kind == 1 and Debug.disable_thrower):
		return
	# Debug density cap - separate from the on/off switches above. Lets a
	# crowd be thinned to a handful, or to one, instead of only ever being
	# fully on or fully off.
	var cap: int = Debug.max_rusher_alive if kind == 0 else Debug.max_thrower_alive
	if _count_alive_kind(kind) >= cap:
		return

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


## A rusher's swing landing - see enemy.gd's melee_hit and is_melee_kind.
func _on_enemy_melee_hit(from_pos: Vector2) -> void:
	player.take_damage(Tuning.ENEMY_CONTACT_DAMAGE, from_pos)


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
