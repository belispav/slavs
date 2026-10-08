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
##
## env_06, 2026-08-15, replaces env_05. Pavel's own image (2816x1536, matches
## the canvas convention already) with the palisade at the top - but instead
## of the palisade's own painted sky/forest above it (what env_01-05 all
## did), the top edge is cut to the actual silhouette of the fence tips:
## every pixel above/between the points is alpha 0, not painted. That gap is
## filled by a separate parallax sky layer (see BG_LAYERS below) scrolling
## behind it, per DIZAJN_pozadie_a_rozlisenie.md SS4e / ref/PROMPTY.md SS4e -
## the concrete stuff (fence, forest) stays baked into the walkable ground so
## it is always in perfect registration with what you walk on; only the
## atmosphere (sky) is a separate, independently-scrolling layer.
##
## The silhouette cut was not a clean geometric crop - it is a per-column
## alpha mask, cleaned up in three passes (colour rule, connected-component
## island removal, then Pavel's own manual touch-up in an image editor for
## the last few spots a tree trunk behind the fence matched the wood colour
## too closely for any of that to catch automatically). Confirmed by direct
## pixel check: 0 partially-transparent pixels anywhere in the image (hard
## alpha, as pixel art wants) - see chat history for the numbers.
##
## REPLACED 2026-09-01 by env_07 (below). Pavel rejected the whole palisade
## boundary after seeing env_06 in gameplay preview: fence read too tall, the
## sky layer behind it read as an unclear blue stripe, and there was no way
## to feel out the parallax speed live. Decision was to drop the built
## boundary (fence/wall) entirely and go the Metal Slug way instead: a
## walkable ledge whose top AND bottom edges are just where the rock
## silhouette stops, no built structure. env_06 is kept on disk and wired to
## BACKGROUND_ALT_PATH as the reference to judge env_07 against.
##
## env_07 = ref/candidates/env_path_v1.png, Pavel's new rock-ledge image
## (2400x1309, RGBA), un-retouched draft - he called it explicitly
## "nie sú dokonalé" (not final) and asked to see it in-game to tune the
## generation prompt, not to ship a finished asset. Known issues, left
## as-is on his instruction:
##   - edge alpha is soft (~50k partially-transparent pixels at the rock
##     silhouette), not the hard 0/255 cut env_06 had.
##   - character-vs-rock scale looks off (rocks read 3-4x too big); Pavel
##     said he would fix this on his end, not done yet.
## Seam measured 8.0 (left/right 6px strip average abs diff) - well inside
## the <=25 rule, tiles cleanly despite being a draft.
##
## REPLACED 2026-09-14 by env_08 (below). Pavel called env_07 "prilis
## pixelata" (too pixelated) after seeing it in gameplay preview - the
## chunky 2-3px blocks in the rock texture, not the ledge concept itself,
## which stays. env_06 is bumped out of BACKGROUND_ALT_PATH and env_07 takes
## its place there, same "reference to judge the new one against" role the
## slot has always had.
##
## env_08 = ref/candidates/env_path_v2.jpg, Pavel's new dirt-path/grass
## image (2752x1536, delivered as JPEG with a flat magenta #FF00FF key
## standing in for what should be transparent - the AI generator this
## project uses cannot output alpha at all, see tools/key_transparency.py's
## own doc comment). Converted to real hard alpha (0/255 only, no partial
## pixels, matching env_06/env_07's own convention - measure_walk_top.py
## below needs that to give a real per-column reading, not a soft-edge
## fudge): distance-to-magenta thresholded at 150 (the file has a clean gap
## between the magenta cluster, dist < ~20, and every real content pixel,
## dist > 207 - nothing to feather), then a magenta-tint DESPILL pass on
## the surviving opaque pixels - JPEG rings the hard magenta/content edge
## and leaves a purple fringe baked into otherwise-real grass-tip colour
## that a threshold alone cannot fix (1.3 % of opaque pixels were tinted,
## pulled back towards neutral by the smaller of their R and B excess over
## G). Connected-component check found the ground one single piece with 0
## stray magenta islands and 0 stray opaque flecks in the sky - the
## threshold alone was clean, the despill was the only real fix needed.
## Neighbour-difference on the walkable band: 36.3 %, against env_07's
## 12.4 % - this is the "too pixelated" complaint measured, not just
## agreed with.
##
## Field height 881 (rows 406-1287, see BG_WALK_TOP/BOTTOM below) clears
## the >=720 rule outright for the first time - every earlier background
## from env_06 on had fallen short of it and shipped anyway on Pavel's call.
##
## Luma of the walkable band was NOT re-measured against the >=80 contrast
## rule (DIZAJN_pozadie_a_rozlisenie.md SS6) - explicitly deferred, Pavel's
## call 2026-09-14: "jas budeme riesit pri finalnej grafike" (contrast gets
## handled with the final art, not this draft). env_07 did not clear that
## rule either, so this is not a new gap, just still open.
## env_09 (2026-10-04) = env_08's picture with a new PixelLab ground surface,
## baked by tools/bake_ground.py: same 2752x1536 size and same top edge, so the
## walk curves and the forest layers are untouched, but the ground is opaque to
## the bottom of the picture - no lower band of forest is ever on screen.
## env_10 (2026-10-04) = the ground made in Nano Banana (two chained sections,
## magenta-keyed edge, see tools/bake_ground_nb.py): 3156x1287, its own top edge
## (env_10_top.json) and ground to the last row (env_10_bottom.json). Pavel
## wants to judge it on the phone against the PixelLab ground (env_09, on the
## STARE POZADIE switch - note env_09 is 1536 tall, so it shows cut at 1287).
## The grounds live in Tuning.GROUNDS; the panel button cycles Debug.ground_key.
## Switching swaps picture, both edges and the camera limit together (they differ
## in size), and a one-screen ground also turns SCENA BEZ SCROLLU on.
const BACKGROUND_PATH := "res://art/env_10.png"   # only the size-independent users


## The ground picked on the panel. Read at build time and on every swap.
func _ground() -> Dictionary:
	return Tuning.GROUNDS[Debug.ground_key]


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
##
## Re-measured 2026-08-15 for env_06 (fence base fully clear of grass by row
## ~500, rocks start intruding on the walkable grass by row ~1010). Field
## height is therefore 510 - short of the >=720 rule in ref/PROMPTY.md SS4b
## (the walkable band should be taller than the screen so the camera has
## something to scroll to). Flagged to Pavel 2026-08-15; he said ship it
## anyway for now ("daj mi to do hry") rather than block on a redo. Camera
## will barely scroll while walking this field - not broken, just less
## depth than the rule asks for. Revisit if it reads as flat on device.
##
## Re-measured 2026-09-01 for env_07 (rock ledge, no built boundary). Alpha
## scan of the actual file: rows 0-238 always transparent, rows 409-1042 are
## opaque across the whole width on every column (the walkable ledge), the
## bands either side of that are the jagged silhouette transition. 409/1042
## is the safe inset - the first/last row the WHOLE width is solid, so feet
## can never stand half on a transparent notch. Field height is 633 - again
## short of the >=720 rule, same situation and same call as env_06: Pavel
## approved shipping this as-is ("publishni mi to do hry", 2026-09-01), art
## is still a draft.
##
## Re-measured 2026-09-14 for env_08 (dirt path/grass, same alpha-scan
## method). Rows 0-275 always transparent, rows 406-1287 opaque across the
## whole width on every column. 406/1287 is the same kind of safe inset as
## before. Field height is 881 - the first background to clear the >=720
## rule outright (every one from env_06 on had shipped short of it).
const BG_WALK_TOP := 406.0
const BG_WALK_BOTTOM := 1287.0

## Per-column top of the walkable ground, in the same row-space as
## BG_WALK_TOP above - one entry per pixel column of BACKGROUND_PATH's
## texture (2752 wide for env_08). Measured once, offline, from the
## picture's own alpha channel by tools/measure_walk_top.py (first row per
## column where alpha == 255); the numbers themselves live in
## art/env_08_top.json, not here - 2752 literals would swamp every other
## comment in this file and cannot be diffed usefully.
##
## REGENERATED 2026-09-14 for env_08: min 276, max 406 (against BG_WALK_TOP's
## conservative 406), mean 343.5 - a 130px jagged range from the grass tufts,
## smaller than env_07's rock silhouette range. walk_top_for_x() below reads
## the array's own length for the tiling period, so nothing here needed to
## change when the column count changed from 2400 to 2752.
##
## ADDED 2026-09-04, Pavel on device: the flat BG_WALK_TOP moved fine but
## read wrong for a Metal Slug ledge - the player walked in a straight line
## while the rock behind them went up and down. This makes the walkable
## edge follow the actual rock silhouette instead; see walk_top_for_x()
## below for how it is sampled, and set_dynamic_top() on player.gd for how
## the player uses it.
##
## KNOWN LIMITATION (Pavel, 2026-09-04): this is the top ENVELOPE of the
## rock only - one height per column, read from where the alpha channel
## first turns solid. A boulder that pokes further into the walkable band
## than its neighbours IS captured (that is the column's minimum), but
## nothing here stops the character walking through a separate rock that
## sits apart from the edge, further into the open ground - the mask only
## knows the picture's outer silhouette, not individual objects drawn on
## top of it. Not fixed here.
##
## Longer-term direction agreed with Pavel: generate future playable-area
## backgrounds WITHOUT rocks/obstacles baked into the walkable edge at all -
## obstacles go in as their own objects (see the _solid()/StaticBody2D
## pattern further down this file), and where a background does need a
## rock border, keep its height uniform so the edge can be a fixed pixel
## offset from GROUND_Y instead of a per-column measurement like this one.
var _walk_top_curve: PackedInt32Array = PackedInt32Array()

## Per-column BOTTOM of the walkable ground - the exact same idea as
## _walk_top_curve above, mirrored: the front edge of the field frays too
## (env_08: rows 1287-1369, see BG_WALK_TOP/BOTTOM's comment), and until
## 2026-09-15 nothing read that, only the flat BG_WALK_BOTTOM. Nobody had
## built it, not a deliberate choice - the per-column curve was only ever
## requested for the top (2026-09-04, the Metal Slug ledge), and it did not
## occur to extend it to the bottom until Pavel asked on device: "toto
## ocividne funguje len na hornom okraji... chceme to aj na spodnom".
## Measured by tools/measure_walk_bottom.py (last row per column where
## alpha == 255, the mirror image of measure_walk_top.py's first row), into
## art/env_08_bottom.json.
var _walk_bottom_curve: PackedInt32Array = PackedInt32Array()

func _read_curve(path: String) -> PackedInt32Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Hranica %s sa nenacitala, pouzivam plochu." % path)
		return PackedInt32Array()
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("Hranica %s ma neocakavany format." % path)
		return PackedInt32Array()
	return PackedInt32Array(parsed)


func _load_walk_top_curve() -> void:
	_walk_top_curve = _read_curve(_ground()["top"])


## The front limit of the current ground; for both grounds the ground is opaque
## to the last row, so it is simply the bottom of the picture. Tuning.walk_edge_inset
## pulls the feet in from it.
func _load_walk_bottom_curve() -> void:
	_walk_bottom_curve = _read_curve(_ground()["bottom"])


## Where the character's feet may stand at the front (rock) edge, at this
## world x - background_top() plus the measured silhouette for that
## picture column, wrapped with the same period the background tiles with
## (_build_background() repeats the texture every texture.get_width()
## units), so this lines up exactly with what is on screen at every repeat.
## Falls back to the flat BG_WALK_TOP if the curve failed to load.
func _ground_top_for_x(world_x: float) -> float:
	if _walk_top_curve.is_empty():
		return background_top() + BG_WALK_TOP
	var width: int = _walk_top_curve.size()
	var col: int = int(fposmod(world_x - LEVEL_LEFT, float(width)))
	return background_top() + float(_walk_top_curve[col])


func walk_top_for_x(world_x: float) -> float:
	return _ground_top_for_x(world_x)


## The bottom-edge mirror of walk_top_for_x() above - same wrap, same
## fallback pattern, read by player.gd's set_dynamic_bottom() instead of
## set_dynamic_top().
func walk_bottom_for_x(world_x: float) -> float:
	var bottom: float = background_top() + BG_WALK_BOTTOM
	if not _walk_bottom_curve.is_empty():
		var width: int = _walk_bottom_curve.size()
		var col: int = int(fposmod(world_x - LEVEL_LEFT, float(width)))
		bottom = background_top() + float(_walk_bottom_curve[col])
	if Debug.fixed_screen:
		bottom = minf(bottom, _scene_bottom())
	return bottom


## World y of the last walkable row of the scene: one screen of ground below the
## first ground row.
func _scene_bottom() -> float:
	return background_top() + Tuning.SCENE_GROUND_ROW + Tuning.SCENE_FIELD_HEIGHT

var player            # untyped on purpose: the script is attached at runtime
var bullets: Array = []
var enemies: Array = []
var _bullet_next: int = 0
## The hero's thrown axe and the breakable barrel (2026-10-03). Untyped for
## the same reason as `player`: scripts attached at runtime.
var axe
var barrels: Array = []
var cauldrons: Array = []
## T22: feet height the props' blocking strips were last fitted to.
var _feet_h_applied: float = -1.0
var _feet_w_applied: float = -1.0
var fx   # fx.gd - blood, splinters, smoke
var corpses   # corpses.gd - bodies of killed enemies (A9, T36)
## A10 slow-motion bookkeeping (real-time ms) and the kill streak that arms it.
var _slowmo_end_ms: int = 0
var _slowmo_next_ms: int = 0
var _streak: int = 0
var _last_kill_ms: int = 0
var _vibrate_cd: float = 0.0
## Hit-stop bookkeeping, real-time milliseconds (Time.get_ticks_msec).
var _hitstop_end_ms: int = 0
var _hitstop_next_ms: int = 0
var _enemy_bark_cd: float = 4.0
var _hero_bark_cd: float = 8.0
## Barrels are stood on the field a few frames in, once the player has been
## clamped onto the walkable band - spawn_point alone may be off it. Set
## back to a few frames after every death so they come back, whole, in
## front of wherever the hero gets up.
var _barrel_place_frames: int = 3
var _spawn_cd: float = 0.0

var kills: int = 0
var deaths: int = 0
var hud: Label
var _alive: int = 0
## Kept so the debug panel can flip its filter live. See _apply_bg_filter().
var _bg_sprite: Sprite2D
var _bg_smooth_applied: bool = false
var _ground_key_applied: String = "pixen_a"
var _decor_key_applied: String = ""
var _decor: Node2D
var _decor_rects: Array = []
var _fixed_screen_applied: bool = false
## FULL SCENE state (Debug.full_scene): left edge of the locked screen in world x,
## and the visible screen width at the moment it was switched on.
var _full_applied: bool = false
var _full_x0: float = 0.0
var _full_w: float = 1280.0
var _strip_applied: float = -1.0
## Parallax2D nodes built from BG_LAYERS entries marked "front": true (drawn
## ahead of the player - currently none; env_05_fg.png was the last one).
## Kept so the "rychlost popredia" panel slider can drive their speed live.
## See _apply_fg_parallax_speed().
var _fg_parallax_layers: Array = []
## Parallax2D nodes built from every BG_LAYERS entry NOT marked "front" (the
## sky and the valley below the ledge). Each element is
## {"layer": Parallax2D, "base": float}: "base" is the entry's own literal
## factor, kept so the panel slider can scale every layer by one number
## without flattening the depth split between them. See
## _apply_bg_parallax_speed().
var _bg_parallax_layers: Array = []


func _ready() -> void:
	# Panel switch ZMRAZIT SVET pauses the tree; everything under main keeps
	# running (hero, his axe and shots, effects) except the nodes that opt in
	# with PROCESS_MODE_PAUSABLE: enemies, cauldrons, enemy shots.
	process_mode = Node.PROCESS_MODE_ALWAYS
	Debug.fixed_screen = Tuning.GROUNDS[Debug.ground_key]["scene"]
	_load_walk_top_curve()
	_load_walk_bottom_curve()
	_build_level()
	_build_player()
	# The moving targets are F1 shooting-range furniture, not content. They
	# exist to give the aim something to track while the controls are tuned,
	# and they only get in the way once there are real enemies.
	if SHOW_AIM_TARGETS:
		_build_targets()
	_build_bullet_pool()
	_build_enemy_pool()
	_build_axe_and_barrel()
	_build_fx()
	_build_hud()
	var overlay_script: GDScript = load("res://scripts/debug_overlay.gd")
	add_child(overlay_script.new())


func _process(delta: float) -> void:
	_vibrate_cd = maxf(_vibrate_cd - delta, 0.0)
	_hitstop_tick()
	_barks(delta)
	if player.global_position.y > Tuning.RESPAWN_Y:
		_restart()
	if Debug.game_reset_requested:
		Debug.game_reset_requested = false
		_reset_game()
	_alive = _count_alive()      # spocitane RAZ za snimku, nie trikrat
	_place_barrel_once()
	if not get_tree().paused:
		_spawn_tick(delta)
	_update_hud()
	_apply_bg_filter()
	_apply_fg_parallax_speed()
	_apply_bg_parallax_speed()
	_refit_prop_blocks()
	if not get_tree().paused:
		_separate_enemies()


## Follows the "rychlost popredia" panel slider (Tuning.fg_parallax_factor)
## so the foreground strip's speed can be found on the device - KROK 2, tried
## 1.15 / 1.3 / 1.5 and picked by Pavel - without a redeploy per try.
func _apply_fg_parallax_speed() -> void:
	for layer in _fg_parallax_layers:
		layer.scroll_scale.x = Tuning.fg_parallax_factor


## Follows the "rychlost pozadia" panel slider (Tuning.bg_parallax_speed) so
## the speed of the layers BEHIND the ground can be found on the device.
##
## A MULTIPLIER on each layer's own BG_LAYERS literal, not an absolute factor:
## with more than one layer back there (sky 0.2, valley 0.35) a single
## absolute value would set both to the same speed and kill the depth between
## them. 1.0 = exactly what the literals say.
func _apply_bg_parallax_speed() -> void:
	for item in _bg_parallax_layers:
		item["layer"].scroll_scale.x = item["base"] * Tuning.bg_parallax_speed


## T22: the barrels' and cauldrons' blocking strips are computed from the feet
## height of a character, so they follow the panel slider.
func _refit_prop_blocks() -> void:
	if is_equal_approx(Tuning.body_feet_height, _feet_h_applied) \
			and is_equal_approx(Tuning.body_feet_width, _feet_w_applied):
		return
	_feet_h_applied = Tuning.body_feet_height
	_feet_w_applied = Tuning.body_feet_width
	for b in barrels:
		b.refit_block()
	for c in cauldrons:
		c.refit_block()
	# Frozen enemies do not run their own physics, so they could not refit their
	# own feet box: the hero's box changed and theirs did not (asymmetric
	# collision, Pavel 2026-10-07). Everybody is refitted from here.
	player.refit_body()
	for e in enemies:
		e.refit_body()


## Push overlapping enemies apart (soft push; only while Tuning.solid_bodies
## is off - T22 replaced it with solid feet).
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
	# T22: with solid bodies the physics engine keeps enemies apart (feet are
	# solid), so the soft nudge below is the old behaviour only.
	if Tuning.solid_bodies:
		return
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
			# T24: an enemy mid-attack is pinned. The other one takes the whole
			# push; two pinned ones simply overlap (pillar 1 allows it).
			var a_locked: bool = a.is_locked()
			var b_locked: bool = b.is_locked()
			if a_locked and b_locked:
				continue
			elif a_locked:
				b.global_position -= push * 2.0
			elif b_locked:
				a.global_position += push * 2.0
			else:
				a.global_position += push
				b.global_position -= push
	# T30: the nudges above must not push anybody below the field.
	for e in live:
		e.clamp_to_field()


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
	if Debug.ground_key != _ground_key_applied:
		_ground_key_applied = Debug.ground_key
		_swap_ground()
	if Debug.fixed_screen != _fixed_screen_applied:
		_fixed_screen_applied = Debug.fixed_screen
		_apply_camera_limits()
	if Debug.full_scene != _full_applied:
		_full_applied = Debug.full_scene
		_apply_full_scene()
	if not is_equal_approx(Tuning.scene_strip_height, _strip_applied):
		_strip_applied = Tuning.scene_strip_height
		_apply_camera_limits()
	var decor_key: String = "%s|%s|%s|%s|%d" % [Debug.decor_on, Debug.ground_key,
		Debug.fixed_screen, Debug.full_scene, int(Tuning.decor_density)]
	if decor_key != _decor_key_applied:
		_decor_key_applied = decor_key
		_build_decor()


## Switch to the ground the panel asks for: picture, both edges, the ground's
## z, the sprite's repeat region and the camera limit all change together.
func _swap_ground() -> void:
	var def: Dictionary = _ground()
	var texture: Texture2D = load(def["tex"]) as Texture2D
	if texture == null:
		return
	_load_walk_top_curve()
	_load_walk_bottom_curve()
	_bg_sprite.texture = texture
	var span: float = (LEVEL_RIGHT - LEVEL_LEFT) + texture.get_width() * 2.0
	_bg_sprite.region_rect = Rect2(0.0, 0.0, span, texture.get_height())
	_bg_sprite.position = Vector2(LEVEL_LEFT - texture.get_width(), background_top())
	_bg_sprite.z_index = _ground_z_index()
	Tuning.shadow_z = _ground_z_index() + 3
	_apply_camera_limits()


# ---------------------------------------------------------------- level ---

## Playable height, in world units: the open ground in the picture.
func field_height() -> float:
	return BG_WALK_BOTTOM - BG_WALK_TOP


## World y of the background picture's top row. Placed so its open ground ends
## on GROUND_Y, which everything else is already measured from.
func background_top() -> float:
	return GROUND_Y - BG_WALK_BOTTOM


func background_height() -> float:
	var texture: Texture2D = load(_ground()["tex"]) as Texture2D
	return float(texture.get_height()) if texture != null else 1536.0


## The z_index the ground sprite (and, one step further back per entry, every
## BG_LAYERS behind-layer) must use to stay behind EVERY character, always.
##
## BUG, FOUND 2026-09-15, SAME DAY AS THE FIRST ONE: fixing behind_z_base in
## _build_parallax_layers() only moved the problem, it did not remove it -
## Pavel reported the player now draws ABOVE the sky (that part was fixed)
## but BELOW the ground sprite itself, head "emerging from behind the edge
## of the play area" as it climbs. Cause: the ground sprite had the exact
## same kind of guessed constant the sky layer had, just a different number
## (-100, not -101), and it never moved - _build_background() set it once
## and this function only ever touched the LAYERS BEHIND it.
##
## The ground is one Sprite2D covering the WHOLE picture at ONE flat
## z_index, but a character's z_index (Tuning.depth_z) IS their world Y -
## it varies continuously from field_top up near the back of the field to
## GROUND_Y at the front. The ground sprite has to sit behind the character
## at EVERY Y a character can reach, not just at GROUND_Y - a character's
## feet are always on the ground, so the ground can never be "in front of"
## them, no matter how far back they stand. A flat -100 held only while
## field_top never got that negative (env_07: -33). env_08's field_top is
## -281, well past -100, so a character near the back was already being
## drawn BEHIND the ground sprite before yesterday's fix, and is STILL
## behind it after that fix, because that fix only touched the layers
## behind the ground, not the ground itself.
##
## Both numbers - the ground's and the behind-layers' - are now the SAME
## derivation, one call, so they cannot drift apart from each other or from
## the field again.
##
## STILL INCOMPLETE, FOUND 2026-09-16 (Pavel: player still disappears right
## at the very top): the first two fixes both measured "how far back can a
## character get" from field_height(), i.e. from the flat BG_WALK_TOP - but
## the PLAYER does not actually stop there. player.gd's set_dynamic_top()
## lets it follow env_08's own per-column top curve instead (see
## WALK_TOP_MAP_PATH / _walk_top_curve above), which is MORE permissive
## than the flat line by design - that is the whole point of having it, so
## the character can walk right up to the true grass edge instead of
## stopping wherever the shortest column allows. The curve's minimum is
## 276, not BG_WALK_TOP's 406 - 130 rows the flat-field math never saw.
## Enemies do NOT use this curve (only player.gd calls set_dynamic_top),
## and their spawn range is already built from field_height(), so this was
## always a player-only gap - matches Pavel only reporting "postava" this
## time, not enemies or bullets too.
##
## Fixed by reading the SAME curve the player actually moves against,
## instead of re-deriving a bound and hoping it stays in sync: the ground
## (and everything behind it) now sits below whichever is more negative of
## the flat field_top and the curve's own worst column. -50 replaces the
## previous -10 margin - big enough to cover player.gd's SIZE.y * 0.5 feet
## offset (27, see set_foot_field/_move_free) with room left over, since
## main.gd has no business hardcoding a number that is really player.gd's.
func _ground_z_index() -> int:
	var worst_row: float = BG_WALK_TOP
	for row in _walk_top_curve:
		if float(row) < worst_row:
			worst_row = float(row)
	var worst_world_y: float = minf(GROUND_Y - field_height(), background_top() + worst_row)
	return mini(-100, int(worst_world_y) - 50)


## The background, repeated sideways for the length of the level.
##
## One Sprite2D with a region wider than the texture and repeat turned on: the
## GPU does the tiling, so a level ten screens long costs the same as one. The
## picture's edges match to within a few shades, which is what makes this
## possible at all.
func _build_background() -> void:
	var texture: Texture2D = load(_ground()["tex"]) as Texture2D
	if texture == null:
		push_warning("Pozadie %s sa nenacitalo." % _ground()["tex"])
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
	sprite.z_index = _ground_z_index()
	Tuning.shadow_z = _ground_z_index() + 3
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
##   front:       true = drawn in front of the player, false/absent = behind
##                the ground. This, not the factor, is what decides where the
##                layer sits in the draw order - see _build_parallax_layers.
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
## a safe bet there). Both panel sliders overwrite it live every frame - a
## "front" entry from Tuning.fg_parallax_factor (_apply_fg_parallax_speed),
## every other entry from its own literal times Tuning.bg_parallax_speed
## (_apply_bg_parallax_speed) - so the literal here is only frame-0's start.
##
## env_06_sky.png added 2026-08-15 (DIZAJN_pozadie_a_rozlisenie.md SS4e /
## ref/PROMPTY.md SS4e). Sky + hazy hills only - the forest/palisade content
## that a "top band" layer originally had (see the git history of this file)
## moved into the ground image itself (env_06) instead, once it became clear
## a separately-scrolling layer can never stay in registration with the
## walkable field, especially once camera movement stops being purely
## horizontal. This layer only fills the gap env_06's own alpha cutout
## leaves above the fence tips. y = -300 puts its bottom edge at row 260 of
## env_06's coordinate space - below every fence-tip notch (measured tips
## ~200-220, deepest gaps ~250), so no sliver of the old black canvas clear
## colour shows through. factor 0.2 is a first guess, not measured against
## motion on device - see "Faktor a test" in ref/PROMPTY.md SS4d/4e.
##
## REPLACED 2026-09-01: env_07_sky.png swaps in for env_06_sky.png, and it is
## Pavel's raw ref/candidates/env_atmosphere_v1_raw.jpg converted straight to
## PNG (3168x1344), kept FULL HEIGHT and uncropped this time - env_06_sky.png
## was a top-560px sky-only crop, and Pavel called the result out as "de
## facto modrý pruh čo absolútne nie je jasné čo je" (just an unclear blue
## stripe) once the hills/treeline that would have explained it were cut
## away. Cropping is left to positioning (y below), not to the file.
##
## y = -615 was picked, not measured, by matching two rows: env_07's own
## average ridge line (335, mean of the first opaque row per column across
## all 2400 columns) against a row inside env_07_sky's treeline/hills band
## (950) that Pavel picked from a side-by-side ("cislo 2 je lepsie" against
## an anchor of 850, then "posun este vyssie" - shifted further to 950).
## y_offset = 335 - 950 = -615 puts that chosen atmosphere row at the same
## world height as the ridge, so at the back of the field (camera at
## cam_min) the treeline sits right where the rock starts, same framing as
## the approved preview. It will drift out of registration as the camera
## moves away from cam_min - factor 0.2 is deliberately slow so that drift
## reads as normal parallax depth, not as a mistake, but this has not been
## checked at every camera position, only the "vzadu" one Pavel approved.
##
## The gap BELOW the ledge (env_07 is transparent under row 1042 too, the
## drop-off side of the rock silhouette) was the same failure mode: standing
## at the front of the field showed flat clear-colour through it. FIXED
## 2026-09-14 by the second entry below rather than by new art - no
## canyon/water asset exists for Pavel to hand over, and this needed none.
##
## Measured on the file itself: row 1042 is the last row opaque across the
## whole width, the silhouette frays from there to ~1210 (opaque share 95 %
## -> 0 %), and rows 1210-1309 are empty. The camera's bottom limit is
## background_top() + background_height() = row 1309, so roughly the lower
## third of the screen was showing that band at the front of the field.
##
## The second entry is env_07_sky.png AGAIN, the same file, placed low
## instead of high. That image is 3168x1344 and only its top ~600 rows are
## sky; from row ~670 down it is dark forest (row-mean luma 96 falling to 26
## at the bottom). The first entry uses the sky half, this one uses the
## forest half: y = +20 puts sky row 1000 at ground row 1020, so its dark
## band covers 1020-1364 - the whole fray plus the empty rows plus margin,
## and it reads as a wooded valley below the drop rather than as a hole.
##
## The two do not fight: entry 0's sprite spans ground rows -615..729 and
## draws in front (z -101 against -102), and rows 239-1042 of the ground are
## opaque, so entry 1 is only ever seen below the ledge.
##
## REPOSITIONED 2026-09-14 for env_08 (ground swap, same env_07_sky.png -
## the atmosphere asset did not change, only what it sits behind). Both
## entries keep their own sky-side anchor row (950 for the top entry, 950 is
## Pavel's own pick from the side-by-side described above; 1000 for the
## bottom entry, this file's pick when it was added) and are re-solved
## against env_08's own ground rows instead of env_07's:
##   top:    ground anchor = 343.5 (mean of env_08's own per-column top
##           curve, was 335 for env_07 - the two ridgelines sit almost the
##           same depth despite looking nothing alike) -> y = 343.5 - 950 =
##           -606.5
##   bottom: ground anchor = 1265 (22px before BG_WALK_BOTTOM's 1287, same
##           lead-in margin the original +20 gave env_07's 1042, so the
##           forest is already solidly dark by the time the silhouette
##           starts fraying rather than transitioning right at the edge)
##           -> y = 1265 - 1000 = 265
## Neither anchor row is re-derived from scratch - both first guesses, still
## unchecked at camera positions away from cam_min, exactly as before.
##
## The factors below are no longer guesses. Tuning.bg_parallax_speed drives
## every behind-layer live from the debug panel (see
## _apply_bg_parallax_speed) as a MULTIPLIER on these literals, which is the
## slider Pavel asked for on 2026-08-15 and got on 2026-09-14. He ran it the
## same day and picked 3.0 - "ruchlost sa mi pacia 3" - against the first
## guesses of 0.2 (sky) and 0.35 (valley). Baked in here as 0.6 and 1.05, and
## the slider is back to 1.0, per the rule that the slider finds the number
## and the data stores it.
##
## 3.0 was the slider's own maximum, so it is a floor on what he wants, not
## necessarily the value he would have landed on with more room. The panel
## range is unchanged, which now reaches 3x these baked values if he wants to
## push further.
##
## NOTE the valley's 1.05: faster than the ground. Physically that is what a
## layer IN FRONT does, and _build_parallax_layers used to read exactly that
## from the factor to decide z_index. It no longer does - placement is the
## explicit "front" flag now (see that function), so this layer stays behind
## the ground and behind the player, which is what Pavel judged on device.
## At 1.05 it is all but glued to the ground; nothing breaks, because unlike
## the ground itself it has no line in the picture that must stay registered.
const BG_LAYERS := [
	{"path": "res://art/env_07_sky.png", "factor": 0.6, "y": -606.5},
	{"path": "res://art/env_07_sky.png", "factor": 1.05, "y": 265.0},
]


## Builds every entry in BG_LAYERS as its own Parallax2D, called right after
## _build_background() so the ground is always in the tree first and every
## parallax layer stacks around it.
##
## Vertical scroll_scale is hardcoded to 1.0 on every layer here - correct
## for layers BEHIND the player (no "front" flag), which must land on
## BG_WALK_TOP/BOTTOM as the camera travels vertically; a different vertical
## rate would drift them out of registration with the walkable field. A
## layer in FRONT of the player ("front": true) does not have to hit any line
## in the picture, so this does not bind it - see
## DIZAJN_pozadie_a_rozlisenie.md §9.2. env_05_fg.png ran 1.3 horizontal
## against this hardcoded 1.0 vertical, which was never a deliberate choice,
## just what this function does unconditionally; worth revisiting once a
## foreground layer returns.
##
## z_index: FIXED 2026-08-15 (KROK 1), FLIPPED BACK 2026-08-15 (SS4e) once
## env_06 stopped being an opaque rectangle. The KROK 1 fix found that env_05
## was ONE OPAQUE image covering its whole rectangle with no transparency
## anywhere, so z_index < -100 (behind it) was entirely hidden and a
## "further away" layer had to draw IN FRONT (z > -100) instead, overpainting
## whatever env_05 had drawn in that region. env_06 breaks that assumption on
## purpose: everything above its fence-tip silhouette is real alpha 0, not
## painted (see the BACKGROUND_PATH comment above). A behind-layer can
## therefore go back to drawing BEHIND the ground (z < -100) and show through
## the cutout correctly, which is also the more intuitive depth ordering.
## This ONLY holds while BACKGROUND_PATH points at an image with real
## transparency above the walkable field - if a future background goes back
## to a fully opaque top edge (like env_05/BACKGROUND_ALT_PATH still is),
## behind-the-ground layers go invisible again for the KROK 1 reason, and
## this formula needs to flip back. Still holds for env_07 (2026-09-01):
## alpha scan confirms rows 0-238 are fully transparent, same condition as
## env_06 had. Layers without a "front" flag get behind_z_base (see below)
## and down, one step further per entry in array order (furthest-first, per
## the doc's §5 table). A "front": true layer keeps +50, ahead of the
## player. The flag replaced a factor > 1 test on 2026-09-14 - see the note
## at the branch itself.
##
## BUG, FIRST FIX 2026-09-15 - INCOMPLETE: behind_z_base used to be the
## literal -101, on the belief that player/enemy z_index (Tuning.depth_z,
## which IS their world Y) "never goes anywhere near this range" - true
## only as long as the walkable field stayed short. env_08's swap grew
## field_height() from env_07's 633 to 881, pushing field_top = GROUND_Y -
## field_height() down to -281 - past -101 - so a character near the top of
## the field got a MORE negative z_index than the sky layer and vanished
## into it. Reported by Pavel 2026-09-15: "postava sa pri hornom okraji
## straca... aj nepriatelia aj gulky" (player, enemies and bullets all
## disappear near the top edge) - all three set their own z_index the same
## way (see player.gd/enemy.gd/bullet.gd), so all three were hit.
##
## First fix derived behind_z_base from field_height() instead of a guessed
## -101 - correct as far as it went, but it left the GROUND SPRITE's own
## z_index as the literal -100, the exact same kind of guess one step
## closer to the camera. Pavel's very next report: player now drew above
## the sky (that part was fixed) but BELOW the ground sprite, "akoby sa
## hlava vynárala spoza okraja hracej plochy" (head emerging from behind
## the edge of the play area) as it climbed - the ground sprite is a single
## flat z_index covering the WHOLE picture, so once field_top passed -100
## too, a character standing far enough back was behind the ground plane
## itself, which makes no sense (the character's feet are always ON the
## ground) but nothing had stopped it from happening.
##
## Both z_indices are now ONE derivation, _ground_z_index() above, so they
## cannot drift apart from each other or from the field a second time:
## behind_z_base is one step further back than the ground itself, whatever
## the ground's own value turns out to be.
func _build_parallax_layers() -> void:
	var behind_z_base: int = _ground_z_index() - 1
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
		# Placement is the entry's own "front" flag, NOT its factor. It used to
		# be "factor < 1.0", which held only while every behind-layer was also
		# slower than the ground - and stopped holding on 2026-09-14, when
		# Pavel's chosen background speed put the valley layer at 1.05 while
		# it still has to draw behind everything. Depth on screen and scroll
		# rate are two separate decisions; this keeps them separate.
		if entry.get("front", false):
			layer.z_index = 50
			_fg_parallax_layers.append(layer)
		else:
			layer.z_index = behind_z_base - behind_count
			behind_count += 1
			_bg_parallax_layers.append({"layer": layer, "base": factor})
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
	player.set_dynamic_top(walk_top_for_x)
	player.set_dynamic_bottom(walk_bottom_for_x)

	_apply_camera_limits()
	player.fire_requested.connect(_on_fire_requested)
	player.died.connect(_on_player_died)


## Scatter the walk-through ground objects over the whole level: seeded, so the same
## ground looks the same every time. Rebuilt whenever the ground, the scene mode, the
## switch or the density changes. They are plain Sprite2Ds - no collision, nobody is
## ever blocked by them (a barrel is the thing that blocks).
func _build_decor() -> void:
	if _decor != null:
		_decor.queue_free()
		_decor = null
	if not Debug.decor_on or Tuning.decor_density < 1.0:
		return
	if _decor_rects.is_empty():
		var file := FileAccess.open("res://art/ground_objects.json", FileAccess.READ)
		if file == null:
			return
		var parsed = JSON.parse_string(file.get_as_text())
		if typeof(parsed) != TYPE_ARRAY:
			return
		_decor_rects = parsed
	var atlas: Texture2D = load("res://art/ground_objects.png") as Texture2D
	if atlas == null or _bg_sprite == null:
		return
	_decor = Node2D.new()
	_decor.z_index = _ground_z_index() + 1
	add_child(_decor)
	move_child(_decor, 0)       # before fx and everything else with this z
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242
	var kinds: Dictionary = {"stone": [], "pebble": [], "tuft": []}
	for r in _decor_rects:
		kinds[r["k"]].append(r)
	var span: float = LEVEL_RIGHT - LEVEL_LEFT
	var avg_band: float = 0.0
	for i in range(0, int(span), 400):
		var x: float = LEVEL_LEFT + i
		avg_band += _decor_bottom_for_x(x) - _ground_top_for_x(x)
	avg_band /= maxf(span / 400.0, 1.0)
	var count: int = int(Tuning.decor_density * (span / 1280.0) * (avg_band / 720.0))
	for n in count:
		var x: float = LEVEL_LEFT + rng.randf() * span
		var top: float = _ground_top_for_x(x) + 12.0
		var bottom: float = _decor_bottom_for_x(x) - 8.0
		if bottom <= top:
			continue
		var y: float = top + rng.randf() * (bottom - top)
		var roll: float = rng.randf()
		var pool: Array = kinds["stone"] if roll < 0.50 else (kinds["pebble"] if roll < 0.75 else kinds["tuft"])
		if pool.is_empty():
			continue
		var r: Dictionary = pool[rng.randi() % pool.size()]
		var tex := AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(r["x"], r["y"], r["w"], r["h"])
		var sp := Sprite2D.new()
		sp.texture = tex
		sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sp.scale = Vector2(2.0, 2.0)
		sp.flip_h = rng.randf() < 0.5
		sp.position = Vector2(x, y - float(r["h"]))   # y = where it sits on the ground
		_decor.add_child(sp)


## FULL SCENE on/off: lock the camera on the screen the hero is in now (whole screen
## is dirt, nothing scrolls) or release it. The hero is boxed into that screen; enemies
## still come from the right edge of it.
func _apply_full_scene() -> void:
	if player == null:
		return
	if Debug.full_scene:
		var vp: Vector2 = get_viewport().get_visible_rect().size
		_full_w = vp.x
		_full_x0 = clampf(player.global_position.x - _full_w * 0.5,
			LEVEL_LEFT, LEVEL_RIGHT - _full_w)
		player.set_foot_field(GROUND_Y - field_height(), GROUND_Y,
			_full_x0 + 40.0, _full_x0 + _full_w - 40.0)
	else:
		player.set_foot_field(GROUND_Y - field_height(), GROUND_Y,
			LEVEL_LEFT + 40.0, LEVEL_RIGHT - 40.0)
	_apply_camera_limits()


## Lowest ground row decor may use: the screen bottom in scene mode, else the walk limit.
func _decor_bottom_for_x(world_x: float) -> float:
	return walk_bottom_for_x(world_x)


func _apply_camera_limits() -> void:
	if player == null:
		return
	if Debug.fixed_screen:
		# Vertical scroll is allowed only between "top strip about one hero tall" and
		# "strip gone" (the walkable ground is one screen tall). FULL SCENE also locks x.
		var x0: float = LEVEL_LEFT - 80.0
		var x1: float = LEVEL_RIGHT + 80.0
		if Debug.full_scene:
			x0 = _full_x0
			x1 = _full_x0 + _full_w
		player.set_camera_limits(x0, x1,
			background_top() + Tuning.SCENE_GROUND_ROW - Tuning.scene_strip_height,
			_scene_bottom())
	elif Touch.config.free_movement:
		# The camera follows the character up and down, stopping at the edges
		# of the picture. That is what lets the field use the whole ground
		# while the forest behind is still seen at full height.
		player.set_camera_limits(LEVEL_LEFT - 80.0, LEVEL_RIGHT + 80.0,
			background_top(), background_top() + background_height())
	else:
		player.set_camera_limits(LEVEL_LEFT - 80.0, LEVEL_RIGHT + 80.0,
			player.field_top - 260.0, GROUND_Y + 200.0)


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
	# Enemies far behind the hero still exist and keep coming (Pavel 2026-10-05) but
	# do not use up the cap, or a long run would starve the spawner.
	if player == null:
		return 0
	var n: int = 0
	for e in enemies:
		if e.active and absf(e.global_position.x - player.global_position.x) \
				< Tuning.ENEMY_COUNT_RANGE:
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
	if Debug.full_scene:
		# Locked screen: arrive just past its right edge.
		x = _full_x0 + _full_w + Tuning.SPAWN_MARGIN * 0.5 + randf() * Tuning.SPAWN_JITTER
	var kind: int = 1 if randf() < Tuning.THROWER_RATIO else 0
	# The brute is rare and has its own switch and cap; a roll that does not
	# produce one falls through to the usual two kinds.
	var brute: bool = not Debug.disable_brute \
		and randi() % Tuning.BRUTE_SPAWN_ONE_IN == 0 \
		and _count_alive_kind(2) < Debug.max_brute_alive
	# Debug panel switches. Force to the other kind if only one is off; if
	# both are off there is nothing left to spawn this tick.
	if kind == 0 and Debug.disable_rusher:
		kind = 1
	elif kind == 1 and Debug.disable_thrower:
		kind = 0
	if brute:
		kind = 2
	elif (kind == 0 and Debug.disable_rusher) or (kind == 1 and Debug.disable_thrower):
		return
	# Debug density cap - separate from the on/off switches above. Lets a
	# crowd be thinned to a handful, or to one, instead of only ever being
	# fully on or fully off.
	var cap: int = Debug.max_rusher_alive if kind == 0 else Debug.max_thrower_alive
	if kind != 2 and _count_alive_kind(kind) >= cap:
		return

	# In free movement there is no floor to walk in on, so they arrive spread
	# across the depth of the field. Dropping them all on one line would make
	# the second axis pointless: nothing would ever need dodging sideways.
	var y: float = GROUND_Y - 120.0
	if Touch.config.free_movement:
		# Anywhere across the open ground. The whole field is on screen, so
		# there is no part of it an enemy could arrive in unseen.
		y = randf_range(maxf(GROUND_Y - field_height(), walk_top_for_x(x)) + 30.0,
			walk_bottom_for_x(x) - 30.0)

	free_enemy.spawn(Vector2(x, y), kind, player)


func _build_fx() -> void:
	fx = Node2D.new()
	fx.set_script(load("res://scripts/fx.gd"))
	add_child(fx)
	fx.setup(_ground_z_index())
	corpses = Node2D.new()
	corpses.set_script(load("res://scripts/corpses.gd"))
	add_child(corpses)
	corpses.setup(fx)
	for e in enemies:
		e.corpse_requested.connect(_on_enemy_corpse)
		e.hurt.connect(_on_body_hurt)
		e.weapon_hit.connect(_on_weapon_hit)
		e.armor_deflected.connect(_on_armor_deflected)
	for b in barrels:
		b.damaged.connect(_on_barrel_damaged)
	player.hurt.connect(_on_player_hurt)


## The axe glanced off a brute's plate: a spray of sparks, no blood.
func _on_armor_deflected(at: Vector2) -> void:
	fx.sparks(at, _away_from_player(at))


## Which way debris flies: away from the hero, who is the one hitting.
func _away_from_player(at: Vector2) -> float:
	return 1.0 if at.x >= player.global_position.x else -1.0


func _on_body_hurt(feet: Vector2, height: float, fatal: bool) -> void:
	fx.body_hit(feet, height, _away_from_player(feet), fatal)


## Package 1 "Uder ma vahu": the hero's weapon landed on an enemy. Each effect
## has its own panel switch (Tuning.fx_* / vibrate_axe_on).
func _on_weapon_hit(at: Vector2, dir: Vector2, fatal: bool, amount: int, crit: bool) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2(_away_from_player(at), 0.0)
	dir = dir.normalized()
	if Tuning.fx_numbers_on:
		fx.damage_number(at, amount, crit)
	# A6: a critical hit makes every effect CRIT_FX_FACTOR times stronger.
	var f: float = Tuning.CRIT_FX_FACTOR if crit else 1.0
	if Tuning.fx_hitstop_on:
		_hit_stop(Tuning.hitstop_ms * f * (Tuning.HITSTOP_KILL_FACTOR if fatal else 1.0) / 1000.0, fatal)
	if Tuning.fx_shake_on:
		player.shake((Tuning.SHAKE_KILL if fatal else Tuning.SHAKE_HIT) * Tuning.shake_strength * f)
	if Tuning.fx_kick_on:
		player.kick(dir * (Tuning.KICK_KILL if fatal else Tuning.KICK_HIT) * Tuning.kick_strength * f)
	if Tuning.vibrate_axe_on:
		_vibrate(int(Tuning.vibrate_axe_ms * f * (1.5 if fatal else 1.0)), Tuning.VIBRATE_AXE_AMP)


## A1: slow the whole game to a crawl for `sec` real seconds. The end is
## checked in _process against the real clock (Time.get_ticks_msec ignores
## Engine.time_scale), so nothing can leave the game stuck slow. Non-kill hits
## are dropped if the last stop began less than HITSTOP_MIN_GAP ago.
func _hit_stop(sec: float, force: bool) -> void:
	var now: int = Time.get_ticks_msec()
	if sec <= 0.0 or (now < _hitstop_next_ms and not force):
		return
	_hitstop_next_ms = now + int(Tuning.HITSTOP_MIN_GAP * 1000.0)
	_hitstop_end_ms = maxi(_hitstop_end_ms, now + int(sec * 1000.0))
	Engine.time_scale = Tuning.HITSTOP_SCALE


func _hitstop_tick() -> void:
	var now: int = Time.get_ticks_msec()
	if _hitstop_end_ms > 0 and (now >= _hitstop_end_ms or not Tuning.fx_hitstop_on):
		_hitstop_end_ms = 0
	if _slowmo_end_ms > 0 and (now >= _slowmo_end_ms or not Tuning.fx_slowmo_on):
		_slowmo_end_ms = 0
	var want: float = 1.0
	if _hitstop_end_ms > 0:
		want = Tuning.HITSTOP_SCALE
	elif _slowmo_end_ms > 0:
		want = Tuning.slowmo_scale
	if not is_equal_approx(Engine.time_scale, want):
		Engine.time_scale = want


## A10: called on every kill. Slow-motion starts when the kill was a brute, or
## the last living enemy near the hero after a streak of quick kills.
func _try_slowmo() -> void:
	var now: int = Time.get_ticks_msec()
	if float(now - _last_kill_ms) / 1000.0 > Tuning.slowmo_gap:
		_streak = 0
	_streak += 1
	_last_kill_ms = now
	if not Tuning.fx_slowmo_on or now < _slowmo_next_ms:
		return
	var brute: bool = false
	var others: bool = false
	for e in enemies:
		if not e.active:
			continue
		if e.hp <= 0:
			brute = e.kind == e.Kind.BRUTE   # the one dying right now
		elif absf(e.global_position.x - player.global_position.x) < Tuning.slowmo_range:
			others = true
	if not (brute or (not others and _streak >= Tuning.slowmo_min_streak)):
		return
	_slowmo_next_ms = now + int(Tuning.SLOWMO_COOLDOWN * 1000.0)
	_slowmo_end_ms = maxi(now, _hitstop_end_ms) + int(Tuning.slowmo_ms)


func _hitstop_clear() -> void:
	_slowmo_end_ms = 0
	_hitstop_end_ms = 0
	Engine.time_scale = 1.0


func _exit_tree() -> void:
	Engine.time_scale = 1.0


## A cauldron went off at `feet`. Every enemy, barrel and other cauldron
## inside the blast ellipse is hit; the hero too if the switch says so.
## Depth (Y) counts double - the blast spreads over the ground, it does not
## reach up the screen as far as it reaches sideways.
func _on_cauldron_exploded(feet: Vector2) -> void:
	var r: float = Tuning.cauldron_radius
	fx.explosion(feet)
	player.shake(14.0)
	for e in enemies:
		if e.active and _in_blast(e.global_position + Vector2(0.0, e.SIZE.y * 0.5), feet, r):
			e.blast(Tuning.CAULDRON_DAMAGE)
	for b in barrels:
		if b.visible and _in_blast(b.global_position, feet, r):
			b.smash()
	for c in cauldrons:
		if c.visible and _in_blast(c.global_position, feet, r):
			c.chain_light()
	if Tuning.cauldron_hurts_player:
		var pf: Vector2 = player.global_position + Vector2(0.0, player.SIZE.y * 0.5)
		if _in_blast(pf, feet, r):
			player.take_damage(1, feet, false, Vector2.ZERO,
				Tuning.push_vector(pf - feet, Tuning.cauldron_push))


func _in_blast(at: Vector2, centre: Vector2, r: float) -> bool:
	var d: Vector2 = at - centre
	d.y *= 2.0
	return d.length() <= r


func _on_barrel_damaged(feet: Vector2, broke: bool) -> void:
	fx.wood_hit(feet, _away_from_player(feet), broke)


func _on_player_hurt(feet: Vector2, height: float, away: float) -> void:
	fx.body_hit(feet, height, away, false, Tuning.FX_BLOOD_PLAYER)
	_vibrate(int(Tuning.vibrate_player_hit_ms), 1.0, true)


## One short buzz, at most one per VIBRATE_MIN_GAP. Does nothing on desktop.
## `amp` scales the panel strength; `force` (the hero being hit) ignores the gap.
func _vibrate(ms: int, amp: float = 1.0, force: bool = false) -> void:
	if not Tuning.vibrate_enabled or (_vibrate_cd > 0.0 and not force):
		return
	_vibrate_cd = Tuning.VIBRATE_MIN_GAP
	Input.vibrate_handheld(ms, clampf(Tuning.vibrate_strength * amp, 0.0, 1.0))


func _on_enemy_corpse(tex: Texture2D, flip: bool, art_scale: Vector2, off: Vector2, feet: Vector2, body_h: float, dir: Vector2, frames: Array) -> void:
	corpses.spawn(tex, flip, art_scale, off, feet, body_h, dir, _away_from_player(feet), frames)


func _on_enemy_died(_at: Vector2) -> void:
	kills += 1
	_try_slowmo()
	if randf() < Tuning.HERO_BARK_ON_KILL:
		Sfx.play(&"hero_bark", player.global_position)


## Random lines - an enemy on screen now and then, the hero while there is a
## fight. Sfx rations voices itself, so a bark that collides with another line
## is simply skipped and its timer restarts.
func _barks(delta: float) -> void:
	_enemy_bark_cd -= delta
	_hero_bark_cd -= delta
	if _enemy_bark_cd <= 0.0:
		var span: float = Tuning.ENEMY_BARK_MAX - Tuning.ENEMY_BARK_MIN
		_enemy_bark_cd = Tuning.enemy_bark_every + randf() * span
		var near: Array = []
		for e in enemies:
			if e.active and absf(e.global_position.x - player.global_position.x) < 700.0:
				near.append(e)
		if not near.is_empty():
			var who = near[randi() % near.size()]
			Sfx.play(&"enemy_bark", who.global_position)
	if _hero_bark_cd <= 0.0:
		_hero_bark_cd = randf_range(Tuning.HERO_BARK_MIN, Tuning.HERO_BARK_MAX)
		if _alive > 0:
			Sfx.play(&"hero_bark", player.global_position)


func _on_enemy_throw(from: Vector2, dir: Vector2) -> void:
	_fire(from, dir, true, Tuning.THROWER_SHOT_SPEED)


## A rusher's swing landing - see enemy.gd's melee_hit and is_melee_kind.
func _on_enemy_melee_hit(from_pos: Vector2, push: Vector2) -> void:
	player.take_damage(Tuning.ENEMY_CONTACT_DAMAGE, from_pos, false,
		Vector2.ZERO, push)


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
	_hitstop_clear()
	_clear_field()
	_spawn_cd = 1.2
	player.respawn()


## Panel RESET: a fresh run - field cleared, props rebuilt, hero back at the
## start with full health, counters zeroed.
func _reset_game() -> void:
	_hitstop_clear()
	_clear_field()
	kills = 0
	deaths = 0
	_spawn_cd = 1.2
	player.respawn()


func _clear_field() -> void:
	if axe != null:
		axe.recall()
	_barrel_place_frames = 2
	if corpses != null:
		corpses.clear()
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

## The axe (see axe.gd) and the barrel (barrel.gd). One axe: the hero has
## to catch it before he can throw again, so there is nothing to pool.
func _build_axe_and_barrel() -> void:
	axe = Area2D.new()
	axe.set_script(load("res://scripts/axe.gd"))
	add_child(axe)
	axe.thrower = player
	axe.caught.connect(player.catch_axe)
	player.throw_requested.connect(_on_throw_requested)

	var barrel_script: GDScript = load("res://scripts/barrel.gd")
	for i in Tuning.BARREL_OFFSETS.size() + Tuning.BARREL_WALL_COUNT:
		var b := Area2D.new()
		b.set_script(barrel_script)
		add_child(b)
		b.hide()
		barrels.append(b)

	var cauldron_script: GDScript = load("res://scripts/cauldron.gd")
	for i in Tuning.CAULDRON_OFFSETS.size():
		var c := Area2D.new()
		c.set_script(cauldron_script)
		add_child(c)
		c.hide()
		c.exploded.connect(_on_cauldron_exploded)
		cauldrons.append(c)


func _place_barrel_once() -> void:
	if Debug.barrels_reset_requested:
		Debug.barrels_reset_requested = false
		_barrel_place_frames = 0
	if _barrel_place_frames < 0:
		return
	_barrel_place_frames -= 1
	if _barrel_place_frames >= 0:
		return
	# Ahead of the hero, to the right - where enemies come from and where
	# the thumb does not cover them - spread over the depth of the field.
	var hero_feet: Vector2 = player.global_position \
		+ Vector2(0.0, player.SIZE.y * 0.5)
	for i in cauldrons.size():
		var cf: Vector2 = hero_feet + Tuning.CAULDRON_OFFSETS[i]
		var ctop: float = walk_top_for_x(cf.x) + Tuning.BARREL_EDGE_INSET
		var cbottom: float = walk_bottom_for_x(cf.x) - Tuning.BARREL_EDGE_INSET
		if cbottom > ctop:
			cf.y = clampf(cf.y, ctop, cbottom)
		cauldrons[i].place(cf)

	var n_loose: int = Tuning.BARREL_OFFSETS.size()
	for i in n_loose:
		var feet: Vector2 = hero_feet + Tuning.BARREL_OFFSETS[i]
		var top: float = walk_top_for_x(feet.x) + Tuning.BARREL_EDGE_INSET
		var bottom: float = walk_bottom_for_x(feet.x) - Tuning.BARREL_EDGE_INSET
		if bottom > top:
			feet.y = clampf(feet.y, top, bottom)
		barrels[i].place(feet)

	# The wall: barrels side by side along the depth (Y), centred on the
	# hero's row and kept inside the walkable band. Each blocks half the
	# spacing either side plus a margin, so there is no gap between two
	# neighbours until one of them is broken.
	var wx: float = hero_feet.x + Tuning.BARREL_WALL_X
	var n_wall: int = Tuning.BARREL_WALL_COUNT
	var step: float = Tuning.BARREL_WALL_SPACING
	var span: float = step * float(n_wall - 1)
	var w_top: float = walk_top_for_x(wx) + Tuning.BARREL_EDGE_INSET
	var w_bottom: float = walk_bottom_for_x(wx) - Tuning.BARREL_EDGE_INSET
	var first: float = hero_feet.y - span * 0.5
	if w_bottom - w_top > span:
		first = clampf(first, w_top, w_bottom - span)
	var depth: float = maxf(Tuning.BARREL_BLOCK_DEPTH, step * 0.5 + 8.0)
	for j in n_wall:
		barrels[n_loose + j].place(Vector2(wx, first + step * float(j)), depth)


func _on_throw_requested(from: Vector2, dir: Vector2) -> void:
	if axe != null and axe.is_held():
		axe.throw(from, dir)


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
