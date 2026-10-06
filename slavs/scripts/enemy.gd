extends CharacterBody2D

## Pooled enemy. Two behaviours for now (plan 3.5 wants 8 types eventually):
##   RUSHER  - closes distance and hurts on contact
##   THROWER - keeps its distance and throws spears
##
## Enemies die in 1-3 hits and are generous to the player, per design pillar 1.
## Defined by ROLE and EQUIPMENT only, never by origin or appearance
## (CLAUDE.md hard content rule).

signal died(at: Vector2)
## The brute's plate stopped a hit - sparks at `at`.
signal armor_deflected(at: Vector2)
## Every hit, fatal or not: feet position, drawn height, whether it died.
## Drives the blood effect (fx.gd).
signal hurt(feet: Vector2, height: float, fatal: bool)
signal throw_requested(from: Vector2, dir: Vector2)
## A rusher's swing landing. Not the same moment as touching the player - see
## RUSHER_MELEE_RANGE and _update_attack_timer.
## `knockback` is this enemy kind's own hit effect (hit_knockback()).
signal melee_hit(from_pos: Vector2, knockback: Vector2)

enum Kind { RUSHER, THROWER, BRUTE }

const SIZE := Vector2(30, 52)

## How far the player has to be to one side before a standing enemy turns to
## face them. Without it, an enemy pressed against the player flips its sprite
## every frame as the player drifts across its column.
const FACING_DEADZONE := 14.0

var kind: int = Kind.RUSHER
var hp: int = 2
var active: bool = false
var target: Node2D

var _flash: float = 0.0
var _throw_cd: float = 0.0
## Each enemy aims for its own depth slightly off the player's, so a crowd
## surrounds rather than forming a single line.
var _depth_offset: float = 0.0
var _weave_time: float = 0.0
var _weave_rate: float = 1.0
## The range this particular thrower holds. Its own, so a group of them does not
## line up on one arc.
var _keep_distance: float = Tuning.THROWER_KEEP_DISTANCE
var _hurtbox: Area2D
var _hurt_shape: CollisionShape2D
## Drawn character, when one has been rendered. Null means the coloured box,
## which is still a perfectly good enemy and is what every unfinished type uses.
## Points at whichever of the two below matches the current kind - built once
## for both kinds up front, since kind can change every time spawn() reuses
## a pooled node.
## How far each clip's body sits from that kind's base clip, in asset pixels.
## Mixamo clips do not agree on where the character stands relative to the
## animation origin, and Blender frames the canvas on that origin - so without
## this the gunman jumps sideways every time he stops to fire.
##
## One per kind, not one shared: both kinds have a clip called "walk" and a
## single dictionary would have them overwrite each other's shift.
var _thrower_shift: Dictionary = {}
var _rusher_shift: Dictionary = {}
## Drawn sprite height per kind, head to feet, computed once in
## _build_sprite_from - see its own comment. Different per kind (gunman
## ~162, rusher ~190 world units), so the hurtbox must be refit in
## spawn() whenever kind changes, not sized once for both.
var _thrower_drawn_height: float = 0.0
var _rusher_drawn_height: float = 0.0
## Whichever of the two above is active. Refit every physics frame (see
## _physics_process) so Tuning.enemy_hurt_height_fraction is live on the
## debug panel, same pattern as player.gd's _drawn_height.
var _drawn_height: float = 0.0
## Points at whichever of the two matches the sprite now on show.
var _clip_shift: Dictionary = {}
var _sprite: AnimatedSprite2D
var _thrower_sprite: AnimatedSprite2D
var _rusher_sprite: AnimatedSprite2D
var _fire_timer: float = 0.0
## Counts down from the start of the fire clip to the muzzle flash; the shot
## leaves when it reaches zero. < 0 = no shot pending.
var _shot_delay: float = -1.0

## RUSHER awareness/attack state - see _think_rusher and _drive_rusher_sprite.
## Sticky once true: an enemy that has noticed the player does not go back to
## looking around, or it would flicker between the two idles at the boundary.
var _aware: bool = false
var _attack_timer: float = 0.0
var _attack_cd: float = 0.0
## Length of the swing now running, and whether its hit has already been
## resolved. Kept per swing rather than recomputed, so the hit lands at the same
## point of the animation even if the clip is measured differently later.
var _attack_len: float = 0.0
var _attack_hit_done: bool = false
## T16: true from the moment the rusher reaches melee range until the player
## gets clearly out of it (RUSHER_MELEE_LEAVE_FACTOR). Hysteresis, so standing
## and walking do not alternate at the range boundary.
var _stopped: bool = false
## T16: the weave offset is frozen while the rusher stands, or the goal point
## oscillated +-46 px and pushed it in and out of range.
var _weave_value: float = 0.0
## T16: walk-clip state with two speed thresholds (see _rusher_clip).
var _walk_clip: bool = false
## T28 walking round obstacles - see Tuning.DETOUR_*. _wish_speed is set by the
## think functions each frame: how fast this enemy WANTS to close in (0 = not
## trying to move closer), so being blocked can be told apart from standing.
var _wish_speed: float = 0.0
var _prev_pos: Vector2 = Vector2.ZERO
var _stuck_time: float = 0.0
var _detour_dir: int = 0
var _clear_time: float = 0.0
var _block_time: float = 0.0
var _hold_dir: int = 0
var _hold_time: float = 0.0

## BRUTE (2026-10-04): slow, armoured in front, grabs and holds the hero.
var _brute_sprite: AnimatedSprite2D
var _brute_shift: Dictionary = {}
var _brute_drawn_height: float = 0.0
## +1 faces right, -1 faces left. Which way the armoured front points - kept
## here rather than read off the sprite, so the box fallback has armour too.
var _face: float = -1.0
var _grabbing: bool = false
var _grab_tick: float = 0.0
var _grab_time: float = 0.0
var _grab_cd: float = 0.0
var _turn_timer: float = 0.0


func _ready() -> void:
	# Lets the debug panel find and despawn enemies by kind without main.gd
	# having to hand out its pool array.
	add_to_group("enemy")
	collision_layer = Tuning.LAYER_ENEMY
	# T25 (2026-10-06): barrels stop enemies exactly like the hero.
	collision_mask = Tuning.LAYER_WORLD | Tuning.LAYER_PROP
	floor_snap_length = 8.0

	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	cs.shape = rect
	add_child(cs)

	# Bullets look for LAYER_TARGET, so the enemy carries a hurtbox on it.
	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = Tuning.LAYER_TARGET
	_hurtbox.collision_mask = 0
	_hurtbox.monitoring = false
	_hurtbox.monitorable = true
	add_child(_hurtbox)
	var hs := CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = SIZE * 1.15          # placeholder, _fit_hurtbox resizes it
	hs.shape = hrect
	_hurtbox.add_child(hs)
	_hurt_shape = hs

	_build_sprite()
	despawn()


## Build the drawn character for the roles that have art.
##
## Both kinds are built here, whether or not their folders are filled yet -
## spawn() picks which one to show. A fresh clone with nothing rendered for
## either gets null back from both and keeps the coloured box, exactly as the
## thrower did on its own before the rusher existed.
func _build_sprite() -> void:
	var thrower_height := [0.0]
	_thrower_sprite = _build_sprite_from(&"idle", Tuning.THROWER_IDLE_ART_DIR, [
		[&"walk", Tuning.THROWER_WALK_ART_DIR, true],
		# Firing is a one-shot: it must end so the enemy can go back to
		# standing, otherwise it reloads forever and never looks like a shot.
		[&"fire", Tuning.THROWER_FIRE_ART_DIR, false, Tuning.THROWER_FIRE_FPS],
	], _thrower_shift, thrower_height,
		Tuning.THROWER_SPRITE_SCALE, Tuning.THROWER_ANIM_FPS)
	_thrower_drawn_height = thrower_height[0]
	var rusher_height := [0.0]
	_rusher_sprite = _build_sprite_from(&"idle_unaware", Tuning.RUSHER_IDLE_ART_DIR, [
		[&"idle_ready", Tuning.RUSHER_IDLE_READY_ART_DIR, true],
		[&"walk", Tuning.RUSHER_WALK_ART_DIR, true],
		# One-shot for the same reason as the thrower's fire clip. Own fps:
		# the swing's timing was picked separately from the cycles.
		[&"attack", Tuning.RUSHER_ATTACK_ART_DIR, false, Tuning.RUSHER_ATTACK_FPS],
	], _rusher_shift, rusher_height,
		Tuning.RUSHER_SPRITE_SCALE, Tuning.RUSHER_ANIM_FPS)
	_rusher_drawn_height = rusher_height[0]
	var brute_height := [0.0]
	_brute_sprite = _build_sprite_from(&"idle", Tuning.BRUTE_IDLE_ART_DIR, [
		[&"walk", Tuning.BRUTE_WALK_ART_DIR, true],
		[&"grab", Tuning.BRUTE_GRAB_ART_DIR, true],
	], _brute_shift, brute_height,
		Tuning.BRUTE_SPRITE_SCALE, Tuning.BRUTE_ANIM_FPS)
	_brute_drawn_height = brute_height[0]
	if _thrower_sprite != null:
		add_child(_thrower_sprite)
	if _rusher_sprite != null:
		add_child(_rusher_sprite)
	if _brute_sprite != null:
		add_child(_brute_sprite)


## One AnimatedSprite2D from a base animation plus any extra clips whose
## folders happen to be filled. base_dir empty means nothing has been
## rendered for this kind yet - returns null, and the caller's coloured box
## fallback takes over, same rule as always.
##
## extra is an Array of [name, art_dir, loop] triples. A triple whose folder
## is empty is skipped rather than failing - partial art (say, only the idle
## rendered so far) still plays, it just cannot show the missing states yet.
func _build_sprite_from(base_anim: StringName, base_dir: String,
		extra: Array, shift_out: Dictionary, height_out: Array,
		art_scale: float, fps: float) -> AnimatedSprite2D:
	var base_frames := SpriteSequence.load_frames(base_dir)
	if base_frames.is_empty():
		return null

	# Every clip is lined up on the base clip's body, so switching animation
	# does not move the character sideways. See _thrower_shift /_rusher_shift
	# and SpriteSequence.body_centre_offset().
	var base_centre := SpriteSequence.body_centre_offset(base_dir, base_frames)
	shift_out[base_anim] = 0.0

	var sheet := SpriteSequence.build_frames(
		base_frames, String(base_anim), fps)
	for item in extra:
		var clip_name: StringName = item[0]
		var dir: String = item[1]
		var loop: bool = item[2]
		var frames := SpriteSequence.load_frames(dir)
		if frames.is_empty():
			continue
		shift_out[clip_name] = \
			SpriteSequence.body_centre_offset(dir, frames) - base_centre
		sheet.add_animation(clip_name)
		# Optional 4th entry: this clip's own fps, else the kind's.
		var clip_fps: float = item[3] if item.size() > 3 else fps
		sheet.set_animation_speed(clip_name, clip_fps)
		sheet.set_animation_loop(clip_name, loop)
		for tex in frames:
			sheet.add_frame(clip_name, tex)

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = sheet
	sprite.animation = base_anim
	# Nearest, or the pixel pass is undone by the GPU smoothing it back.
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * art_scale
	sprite.z_index = -1

	# Feet on the bottom of the collision box, not on the bottom of the image -
	# the render leaves empty rows below the character from its margin.
	var height: float = float(base_frames[0].get_height())
	var margin: float = float(SpriteSequence.foot_margin(base_frames))
	sprite.position.y = SIZE.y * 0.5 \
		- (height * 0.5 - margin) * art_scale

	# The true body height, head to feet - same fix as player.gd's _drawn_height.
	# Canvas height minus only the foot margin still counts the empty rows
	# above the head as body, which is the bug: it put the hurtbox at roughly
	# the bottom 45% of the drawing (see CLAUDE.md TODO, reported 2026-08-13).
	var top_margin: float = float(SpriteSequence.head_margin(base_frames))
	height_out[0] = (height - margin - top_margin) * art_scale

	sprite.visible = false
	sprite.play()
	return sprite


## Match the hurt area to whichever kind is actually being shown.
##
## Same idea as player.gd's _fit_hurtbox: sized from the DRAWN height, hung
## from the feet, narrower than the drawing on purpose (arms swing wide).
## Called from spawn() - because the two kinds are drawn at different
## heights, a box fitted for one kind is wrong on the other - and every
## physics frame, so the debug-panel slider is live on enemies already on
## screen.
func _fit_hurtbox(drawn_height: float) -> void:
	if drawn_height <= 0.0 or _hurt_shape == null:
		return
	var rect := _hurt_shape.shape as RectangleShape2D
	if rect == null:
		return
	var tall: float = drawn_height * Tuning.enemy_hurt_height_fraction
	rect.size = Vector2(Tuning.ENEMY_HURT_WIDTH, tall)
	# Feet at +SIZE.y/2, same convention as the collision box above.
	_hurt_shape.position.y = SIZE.y * 0.5 - tall * 0.5 - (drawn_height - tall) * 0.5


func spawn(pos: Vector2, new_kind: int, player: Node2D) -> void:
	global_position = pos
	kind = new_kind
	target = player
	match kind:
		Kind.RUSHER: hp = Tuning.RUSHER_HP
		Kind.THROWER: hp = Tuning.THROWER_HP
		Kind.BRUTE: hp = Tuning.BRUTE_HP
	_face = -1.0
	_release_grab()
	velocity = Vector2.ZERO
	_flash = 0.0
	_throw_cd = randf() * Tuning.THROWER_INTERVAL
	_depth_offset = randf_range(-Tuning.ENEMY_DEPTH_SPREAD,
		Tuning.ENEMY_DEPTH_SPREAD)
	_weave_time = randf() * TAU
	_weave_rate = Tuning.ENEMY_WEAVE_SPEED * randf_range(0.6, 1.4)
	_keep_distance = Tuning.THROWER_KEEP_DISTANCE * randf_range(
		1.0 - Tuning.THROWER_DISTANCE_SPREAD,
		1.0 + Tuning.THROWER_DISTANCE_SPREAD)
	active = true
	_fire_timer = 0.0
	_shot_delay = -1.0
	_aware = false
	_attack_timer = 0.0
	_attack_cd = 0.0
	# Pooled nodes are reused mid-swing, so the swing's own state resets too.
	_attack_len = 0.0
	_attack_hit_done = false
	_stopped = false
	_weave_value = 0.0
	_walk_clip = false
	_wish_speed = 0.0
	_prev_pos = pos
	_stuck_time = 0.0
	_detour_dir = 0
	_clear_time = 0.0
	_block_time = 0.0
	_hold_time = 0.0

	# Each kind shows only its own body. A rusher wearing the gunman's sprite
	# would be a lie the player would learn to read wrongly.
	match kind:
		Kind.THROWER:
			_sprite = _thrower_sprite
			_clip_shift = _thrower_shift
			_drawn_height = _thrower_drawn_height
		Kind.BRUTE:
			_sprite = _brute_sprite
			_clip_shift = _brute_shift
			_drawn_height = _brute_drawn_height
		_:
			_sprite = _rusher_sprite
			_clip_shift = _rusher_shift
			_drawn_height = _rusher_drawn_height
	_fit_hurtbox(_drawn_height)
	if _thrower_sprite != null:
		_thrower_sprite.visible = kind == Kind.THROWER
	if _rusher_sprite != null:
		_rusher_sprite.visible = kind == Kind.RUSHER
	if _brute_sprite != null:
		_brute_sprite.visible = kind == Kind.BRUTE
	show()
	set_physics_process(true)
	set_deferred("collision_layer", Tuning.LAYER_ENEMY)
	set_deferred("monitorable", true)
	_hurtbox.set_deferred("monitorable", true)
	queue_redraw()


func despawn() -> void:
	_release_grab()
	active = false
	hide()
	set_physics_process(false)
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", false)
	# The body itself has to leave the enemy layer too, not just stop moving and
	# stop being drawn. Without this a killed enemy leaves its collider standing
	# where it fell, and walking over that spot costs a life to something
	# invisible that is not there.
	set_deferred("collision_layer", 0)


## Whether this enemy's damage comes from a swing (melee_hit) rather than from
## its body touching the player. Read by player.gd's hurtbox handler, which
## otherwise treats any enemy contact as a hit - a rule that stopped being
## true the moment a rusher's attack became a timed swing instead of a shove.
func is_melee_kind() -> bool:
	return kind == Kind.RUSHER


## Nothing of an enemy may be below the playing field (T30, Pavel 2026-10-06):
## the bottom limit is the one the hero obeys, converted for this body's own
## feet offset. Public: main.gd calls it again after pushing enemies apart.
## Only the bottom is limited here.
func clamp_to_field() -> void:
	if target == null or not target.has_method("walk_y_limits"):
		return
	var lim: Vector2 = target.walk_y_limits(global_position.x)
	var hi: float = lim.y + (target.SIZE.y - SIZE.y) * 0.5
	if global_position.y > hi:
		global_position.y = hi
		velocity.y = minf(velocity.y, 0.0)


## Called by the player's bullets (via the hurtbox).
func hit() -> void:
	damage(1)


## A hit that knows which way the weapon was travelling. Returns false when
## the brute's front plate stops it - the axe then bounces back (axe.gd).
## Everything else just takes the hit.
func hit_from(travel: Vector2) -> bool:
	if kind == Kind.BRUTE and active and travel.x * _face < -0.2:
		Sfx.play(&"armor_clang", global_position)
		armor_deflected.emit(global_position + Vector2(_face * 24.0, -60.0))
		return false
	damage(1)
	return true


## A cauldron's blast - armour does not stop it (Pavel 2026-10-04).
func blast(amount: int) -> void:
	damage(amount)


func damage(amount: int) -> void:
	if not active:
		return
	hp -= amount
	_flash = 1.0
	hurt.emit(global_position + Vector2(0.0, SIZE.y * 0.5), _drawn_height, hp <= 0)
	if hp <= 0:
		Sfx.play(&"enemy_death", global_position)
		if randf() < Tuning.ENEMY_DEATH_VOICE_CHANCE:
			Sfx.play(&"enemy_death_voice", global_position)
	else:
		Sfx.play(&"enemy_hit", global_position)
	if hp <= 0:
		died.emit(global_position)
		despawn()


func _physics_process(delta: float) -> void:
	var free: bool = Touch.config.free_movement

	if free:
		# No floor to stand on, so no gravity. Depth is just another axis, and
		# the vertical speed is left alone here - zeroing it every frame would
		# undo the easing that stops enemies snapping onto the player's line.
		pass
	elif not is_on_floor():
		velocity.y = minf(velocity.y + Tuning.ENEMY_GRAVITY * delta, 1800.0)
	else:
		velocity.y = 0.0

	# State, not decoration - see _thrower_clip for why this cannot live there.
	_fire_timer = maxf(_fire_timer - delta, 0.0)
	if _shot_delay >= 0.0:
		_shot_delay -= delta
		if _shot_delay < 0.0:
			_release_shot()

	_wish_speed = 0.0
	if target != null:
		match kind:
			Kind.RUSHER:
				_think_rusher(free, delta)
			Kind.THROWER:
				_think_thrower(delta, free)
			Kind.BRUTE:
				_think_brute(delta, free)
		_avoid_obstacles(delta)

	# An enemy mid-attack stands still. Its clip has the feet planted, so a body
	# that keeps travelling reads as sliding on ice - caught by Pavel on the
	# thrower, which kept closing on the player through its whole firing
	# animation without moving its legs.
	#
	# Deliberately for every kind, not just the thrower: an attack is a
	# commitment, and it also gives the player a readable moment where an enemy
	# has chosen to shoot instead of chase. Any future enemy type gets this free.
	if _is_attacking():
		velocity = Vector2.ZERO

	move_and_slide()
	_keep_out_of_the_left()
	clamp_to_field()
	# Depth is Y. The sprite's own z_index is relative to this, so it keeps
	# sitting behind the body's flash exactly as before.
	z_index = Tuning.depth_z(global_position.y)
	# Redraw ONLY while the hit flash is fading. Moving a Node2D does not need
	# a redraw, and 34 pointless redraws per frame cost real frame time on a
	# phone — which shows up as the controls feeling sticky.
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 6.0, 0.0)
		queue_redraw()
	elif Debug.show_strike_zone and kind == Kind.RUSHER:
		queue_redraw()   # strike zone overlay, debug only
	# Cheap enough to redo every frame, and it is what makes the hurtbox
	# slider in the debug panel actually live instead of only taking effect
	# after the next redeploy - same reasoning as player.gd's own call.
	_fit_hurtbox(_drawn_height)
	_drive_sprite(delta)


## Pick the clip from what the enemy is actually doing. Dispatches by kind -
## the thrower's states are speed/firing, the rusher's are awareness/attack.
func _drive_sprite(delta: float) -> void:
	if _sprite == null or not _sprite.visible:
		return

	var wanted: StringName
	match kind:
		Kind.THROWER:
			wanted = _thrower_clip(delta)
		Kind.RUSHER:
			wanted = _rusher_clip()
		Kind.BRUTE:
			if _grabbing:
				wanted = &"grab"
			elif velocity.length() > Tuning.ENEMY_WALK_SPEED_MIN:
				wanted = &"walk"
			else:
				wanted = &"idle"
		_:
			wanted = &"idle"

	var fallback := &"idle_unaware" if kind == Kind.RUSHER else &"idle"
	if not _sprite.sprite_frames.has_animation(wanted):
		wanted = fallback
	if _sprite.animation != wanted:
		_sprite.play(wanted)

	# The brute's facing is decided in _think_brute (it is gameplay: the
	# armour points that way), the sprite only follows it.
	if kind == Kind.BRUTE:
		_sprite.flip_h = _face > 0.0
	# Sprites are rendered facing left, which is the way enemies travel. Flip
	# only when one is pushed back to the right.
	elif absf(velocity.x) > Tuning.ENEMY_WALK_SPEED_MIN:
		_sprite.flip_h = velocity.x > 0.0
	elif target != null:
		# Not really moving - holding range, firing, or pressed in melee.
		# Face the player instead of freezing on whichever way the last step
		# happened to point. Caught on the thrower: it backs off to its
		# preferred distance moving right (flip_h true), stops, and then
		# fires with its back turned - nothing after that ever pointed it
		# at the player again, because flip_h was only ever set from motion.
		#
		# The deadzone matters. A rusher pressed against the player sits within
		# a pixel or two of the same column, so an exact comparison flipped the
		# sprite back and forth every frame as the player nudged around - which
		# is the "preblikávanie" Pavel saw. Below the deadzone, keep facing
		# whichever way it already faces.
		var dx: float = target.global_position.x - global_position.x
		if absf(dx) > FACING_DEADZONE:
			_sprite.flip_h = dx > 0.0

	# Cancel the clip's own idea of where the character stands. Applied here
	# rather than once at build time because it has to follow flip_h too:
	# mirroring the texture about the sprite's origin mirrors this shift with
	# it, so facing right needs the opposite sign.
	var shift: float = _clip_shift.get(_sprite.animation, 0.0)
	if _sprite.flip_h:
		shift = -shift
	# The sprite's own scale: the two kinds are drawn at different multiples.
	_sprite.position.x = -shift * _sprite.scale.y


## Firing wins while it lasts, then walking or standing by speed. The threshold
## is not zero because holding a distance means constant small corrections, and
## a walk cycle re-triggered every few frames looks like a shiver.
## Playing an attack clip: firing for the thrower, swinging for the rusher.
## Both plant the feet, so both root the body - see _physics_process.
func _is_attacking() -> bool:
	return _fire_timer > 0.0 or _attack_timer > 0.0


## T24: an enemy in the middle of its attack is locked in place. Read by
## main.gd's _separate_enemies, which must not nudge it - that nudge was the
## sliding (the body's own velocity was already zeroed during the swing).
func is_locked() -> bool:
	return _is_attacking()


## What a hit from this enemy does to the hero's movement (config in tuning.gd,
## one entry per kind). Vector2.ZERO = none.
func hit_knockback() -> Vector2:
	match kind:
		Kind.RUSHER:
			return Tuning.RUSHER_HIT_KNOCKBACK
		Kind.THROWER:
			return Tuning.THROWER_HIT_KNOCKBACK
		_:
			return Tuning.BRUTE_HIT_KNOCKBACK


## The timer itself is counted down in _physics_process, NOT here. It used to
## be decremented in this function, which is only reached from _drive_sprite -
## and _drive_sprite returns immediately when there is no sprite. An enemy still
## using the coloured box fallback therefore never ran its timer down, and once
## _fire_timer started rooting the body in place that would have frozen every
## unrendered enemy type permanently after its first shot.
func _thrower_clip(_delta: float) -> StringName:
	if _fire_timer > 0.0:
		return &"fire"
	if velocity.length() > Tuning.ENEMY_WALK_SPEED_MIN:
		return &"walk"
	return &"idle"


## Unaware beats everything - an enemy that has not noticed the player has no
## business swinging or watching. Once aware: attacking, then walking while
## closing, then the ready idle while it holds position between swings.
func _rusher_clip() -> StringName:
	if not _aware:
		return &"idle_unaware"
	if _attack_timer > 0.0:
		return &"attack"
	# Two thresholds (T16): start walking above RUSHER_WALK_START_SPEED, stop
	# below ENEMY_WALK_SPEED_MIN. A single threshold flipped the clip every
	# frame while the speed hovered around it.
	var speed: float = velocity.length()
	if _walk_clip:
		if speed < Tuning.ENEMY_WALK_SPEED_MIN:
			_walk_clip = false
	elif speed > Tuning.RUSHER_WALK_START_SPEED:
		_walk_clip = true
	return &"walk" if _walk_clip else &"idle_ready"


## Enemies do not walk left past the player, and the ones the player leaves
## behind are recycled.
##
## The first version pinned them to the player's x. That does hold the rule, but
## it drags: run to the right and every enemy is carried along at the player's
## speed, pinned to the same column, which looks like teleporting and is exactly
## what it is. An enemy overtaken by the player is chaff that has served its
## purpose - it goes back to the pool and the spawner sends another from the
## right, where they belong.
func _keep_out_of_the_left() -> void:
	if target == null:
		return
	if global_position.x < target.global_position.x - Tuning.ENEMY_CULL_BEHIND:
		despawn()
		return
	# Their own leftward movement still stops at the player. Nothing is moved
	# here, only prevented.
	var limit: float = target.global_position.x + Tuning.ENEMY_KEEP_RIGHT_MARGIN
	if global_position.x < limit and velocity.x < 0.0:
		velocity.x = 0.0


func _think_rusher(free: bool, delta: float) -> void:
	var speed: float = Tuning.RUSHER_SPEED * Tuning.rusher_speed_scale

	# Notices the player once they are within range on the ground plane.
	# Sticky - see the _aware declaration for why it never turns back off.
	if not _aware and absf(global_position.x - target.global_position.x) \
			<= Tuning.enemy_detection_range:
		_aware = true

	if not _aware:
		# Standing still and looking around, not idling in place mid-stride.
		velocity = velocity.move_toward(Vector2.ZERO, speed * 6.0 * delta)
		_attack_timer = 0.0
		return

	var in_range: bool
	var enter_range: float = Tuning.rusher_melee_range
	# Once stopped, the player has to get clearly out of reach before the
	# rusher walks again (T16).
	var hold_range: float = enter_range * Tuning.RUSHER_MELEE_LEAVE_FACTOR
	if not free:
		# On a floor there is only one axis to close. The gap is measured from
		# the enemy back to the player, and enemies are always to the right, so
		# it is positive while there is ground to cover.
		var gap: float = global_position.x - target.global_position.x
		in_range = gap <= (hold_range if _stopped else enter_range)
		_stopped = in_range
		if not in_range:
			velocity.x = -speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * 6.0)
	else:
		# Head for the player, not for the player's column.
		#
		# Closing X and depth separately made them arrive on the player's
		# vertical line and stop there, still far above or below - lined up
		# rather than converging, and never actually reaching what they came
		# to hit. Moving along the whole vector curves them in.
		if not _stopped:
			_weave_value = _weave()
		var to_target: Vector2 = target.global_position \
			+ Vector2(0.0, _depth_offset + _weave_value) - global_position
		# T26 (2026-10-06): REACH is measured to the hero himself, not to the
		# offset goal point. It used to use the goal point, so each rusher's
		# strike zone was shifted up or down by its own depth offset + weave
		# (up to +-80 px) - the zone was not centred on the hero (Pavel).
		# The offset now only shapes the approach path.
		var distance: float = to_target.length()
		if distance < 12.0:
			# Arrived at its own goal point but not yet in reach (small range
			# setting): aim at the hero instead of standing there.
			to_target = target.global_position - global_position
			distance = maxf(to_target.length(), 0.001)
		# T29: it stops when the hero is within the stop distance sideways AND
		# lined up in depth - otherwise the swing could never land (the zone is
		# a thin slice in depth). Wider limits while already stopped.
		var dx_abs: float = absf(target.global_position.x - global_position.x)
		var dy_abs: float = absf(target.global_position.y - global_position.y)
		var depth_enter: float = Tuning.rusher_strike_depth
		var depth_hold: float = depth_enter * 1.25
		in_range = dx_abs <= (hold_range if _stopped else enter_range) \
			and dy_abs <= (depth_hold if _stopped else depth_enter)
		_stopped = in_range

		if not in_range:
			var wish: Vector2 = to_target / distance * speed
			# Depth still moves slower than the ground plane, or a body
			# dropping from above outruns one walking in from the right.
			wish.y *= 0.55
			velocity = velocity.move_toward(wish, speed * 6.0 * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, speed * 6.0 * delta)

	_wish_speed = 0.0 if in_range else speed
	_update_attack_timer(in_range, delta)


## Drives the attack/ready-idle cycle once a rusher has closed to melee range,
## and fires the hit itself. The swing lands the moment it triggers, not on
## contact - see the RUSHER_ATTACK_* comment in tuning.gd for the reasoning
## and for what is still a placeholder about the timing.
func _update_attack_timer(in_range: bool, delta: float) -> void:
	# A swing that has STARTED runs to the end, in range or not.
	#
	# This used to be the other way round: stepping out of reach zeroed
	# _attack_timer, so the rusher dropped its swing mid-animation and walked
	# after the player instead. Caught by Pavel 2026-08-13 - "uberá mi to na
	# šanci sa uhýbať", and he was right, because there was nothing to dodge:
	# the attack was never a commitment the enemy could be punished for.
	if _attack_timer > 0.0:
		_attack_timer = maxf(_attack_timer - delta, 0.0)
		# The club connects PART-WAY through the swing, not on its first frame,
		# and the range is checked at that moment. That is what makes stepping
		# back a real dodge rather than a cosmetic one.
		if not _attack_hit_done:
			var elapsed: float = _attack_len - _attack_timer
			if elapsed >= _attack_len * Tuning.rusher_attack_hit_at:
				_attack_hit_done = true
				if _strike_connects():
					melee_hit.emit(global_position, hit_knockback())
		return
	if not in_range:
		_attack_cd = Tuning.RUSHER_ATTACK_INTERVAL * 0.5
		return
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		_attack_cd = Tuning.RUSHER_ATTACK_INTERVAL
		_attack_len = _attack_anim_duration()
		_attack_timer = _attack_len
		_attack_hit_done = false
		# Not every swing - a shout on each one, from a crowd, is a choir.
		if randf() < Tuning.RUSHER_SHOUT_CHANCE:
			Sfx.play(&"rusher_shout", global_position)


## Which way this enemy faces: +1 right, -1 left. The art faces left, flip_h
## turns it right.
func _facing() -> float:
	if _sprite != null and _sprite.visible:
		return 1.0 if _sprite.flip_h else -1.0
	if target != null and target.global_position.x > global_position.x:
		return 1.0
	return -1.0


## Where the club lands, in world x (T29).
func _strike_x() -> float:
	return global_position.x + _facing() * Tuning.rusher_strike_forward


## The swing's hit: the hero's body overlaps the zone around the landing point
## (STRIKE_WIDTH wide) and he is within STRIKE_DEPTH of this enemy in depth.
func _strike_connects() -> bool:
	if target == null:
		return false
	var half: float = Tuning.rusher_strike_width * 0.5 + Tuning.PLAYER_HURT_WIDTH * 0.5
	return absf(target.global_position.x - _strike_x()) <= half \
		and absf(target.global_position.y - global_position.y) <= Tuning.rusher_strike_depth


## How long the attack clip actually runs, read from the art itself once it
## exists. RUSHER_ATTACK_ANIM_TIME (0.35s) was a guess made before any art
## was rendered; the real Slash clip came out to 39 frames at 30fps = 1.3s,
## more than triple that. Caught by Pavel as "the attack animation looks
## unfinished" - it was: the code was switching the sprite away from
## "attack" a second into a 1.3 second swing, every single time. Falls back
## to the constant only when there is no "attack" clip to measure (box
## fallback, or before render_enemy.ps1 has been run for this kind).
func _attack_anim_duration() -> float:
	if _sprite != null and _sprite.sprite_frames != null \
			and _sprite.sprite_frames.has_animation(&"attack"):
		var frames: int = _sprite.sprite_frames.get_frame_count(&"attack")
		var fps: float = _sprite.sprite_frames.get_animation_speed(&"attack")
		if fps > 0.0:
			return float(frames) / fps
	return Tuning.RUSHER_ATTACK_ANIM_TIME


func _think_thrower(delta: float, free: bool) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = absf(to_target.x)
	var dir: float = signf(to_target.x)
	var speed: float = Tuning.THROWER_SPEED * Tuning.thrower_speed_scale

	# hold the preferred range: close in if far, back off if too close
	if dist > _keep_distance + 60.0:
		velocity.x = dir * speed
		_wish_speed = speed
	elif dist < _keep_distance - 60.0:
		velocity.x = -dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 4.0 * delta)

	if free:
		_track_depth(speed * 0.8)

	_throw_cd -= delta
	if _throw_cd <= 0.0 and dist < Tuning.THROWER_RANGE:
		_throw_cd = Tuning.THROWER_INTERVAL
		# Start the clip now; the shot itself leaves on the muzzle flash
		# (_release_shot). The raise-and-aim before it is the player's
		# warning - a shot that left as the rifle started to rise could not
		# be read, and dodging is the whole answer to a gunman.
		_fire_timer = Tuning.THROWER_FIRE_TIME
		_shot_delay = Tuning.THROWER_SHOT_DELAY


## The shot, from the muzzle of the drawn arquebus towards the player's body.
func _release_shot() -> void:
	if not active or target == null:
		return
	var face: float = signf(target.global_position.x - global_position.x)
	if is_zero_approx(face):
		face = 1.0
	var muzzle: Vector2 = global_position + Vector2(
		face * Tuning.THROWER_MUZZLE_FORWARD,
		SIZE.y * 0.5 - Tuning.THROWER_MUZZLE_HEIGHT)
	var aim_at: Vector2 = target.global_position + Vector2(0.0, -Tuning.THROWER_AIM_RAISE)
	throw_requested.emit(muzzle, (aim_at - muzzle).normalized())
	Sfx.play(&"gunshot", muzzle)


## T28: walking round an obstacle (barrel wall). Runs after the think function,
## so it may overrule the velocity it chose. See Tuning.DETOUR_* for the rule.
func _avoid_obstacles(delta: float) -> void:
	var moved: Vector2 = global_position - _prev_pos
	_prev_pos = global_position
	if _wish_speed <= 0.0 or _is_attacking() or _grabbing:
		_stuck_time = 0.0
		_detour_dir = 0
		_clear_time = 0.0
		_hold_time = 0.0
		return

	if _detour_dir == 0:
		# Just after a detour, keep going the same way along Y for a moment.
		if _hold_time > 0.0:
			_hold_time -= delta
			velocity.y = _hold_dir * _wish_speed * Tuning.DETOUR_Y_FACTOR
			return
		if moved.length() / maxf(delta, 0.0001) < _wish_speed * Tuning.DETOUR_STUCK_FRACTION:
			_stuck_time += delta
		else:
			_stuck_time = maxf(_stuck_time - delta * 2.0, 0.0)
		if _stuck_time < Tuning.DETOUR_STUCK_TIME:
			return
		# Stuck: pick ONE direction along Y - towards the hero's row, or by
		# chance when he is level with us.
		var dy: float = target.global_position.y - global_position.y
		if absf(dy) > 10.0:
			_detour_dir = 1 if dy > 0.0 else -1
		else:
			_detour_dir = 1 if randf() < 0.5 else -1
		_clear_time = 0.0
		_block_time = 0.0

	# Detour running.
	var toward: float = signf(target.global_position.x - global_position.x)
	if is_zero_approx(toward):
		toward = -1.0
	var x_free: bool = not test_move(global_transform, Vector2(toward * 10.0, 0.0))

	# Edge of the field: turn the other way. Also when something blocks Y.
	var turn: bool = false
	if target.has_method("walk_y_limits"):
		var lim: Vector2 = target.walk_y_limits(global_position.x)
		if _detour_dir < 0 and global_position.y <= lim.x + 2.0:
			turn = true
		elif _detour_dir > 0 and global_position.y >= lim.y - 2.0:
			turn = true
	var cmd_y: float = _wish_speed * Tuning.DETOUR_Y_FACTOR
	if absf(moved.y) / maxf(delta, 0.0001) < cmd_y * 0.25:
		_block_time += delta
		if _block_time > 0.3:
			turn = true
	else:
		_block_time = 0.0
	if turn:
		_detour_dir = -_detour_dir
		_block_time = 0.0
		_clear_time = 0.0

	velocity.y = _detour_dir * cmd_y
	if x_free:
		velocity.x = toward * _wish_speed
		_clear_time += delta
		if _clear_time >= Tuning.DETOUR_CLEAR_TIME:
			_hold_dir = _detour_dir
			_hold_time = Tuning.DETOUR_HOLD
			_detour_dir = 0
			_stuck_time = 0.0
			_clear_time = 0.0
	else:
		velocity.x = 0.0
		_clear_time = 0.0


## A sideways drift across the approach, so the path curves instead of being a
## ruled line. Each enemy has its own phase and rate, so a crowd does not weave
## in unison - which would look even more mechanical than a straight line.
func _weave() -> float:
	_weave_time += get_physics_process_delta_time() * _weave_rate
	return sin(_weave_time) * Tuning.ENEMY_WEAVE_AMPLITUDE


## Slow, straight at the hero. Turns to face him only slowly (BRUTE_TURN_TIME),
## which is the window for getting round behind the plate. In reach on the
## hero's own row he grabs: the hero is held in front of him and loses a life
## every BRUTE_GRAB_TICK until dead - Pavel 2026-10-04: "istá smrť" for now.
func _think_brute(delta: float, free: bool) -> void:
	var dx: float = target.global_position.x - global_position.x
	var want_face: float = signf(dx) if absf(dx) > FACING_DEADZONE else _face
	if want_face != _face:
		_turn_timer += delta
		if _turn_timer >= Tuning.BRUTE_TURN_TIME:
			_face = want_face
			_turn_timer = 0.0
	else:
		_turn_timer = 0.0

	if _grabbing:
		velocity = Vector2.ZERO
		_grab_time += delta
		_grab_tick -= delta
		# Held in front of the brute's chest.
		target.global_position = global_position + Vector2(
			_face * Tuning.BRUTE_HOLD_DISTANCE, 0.0)
		if _grab_tick <= 0.0:
			_grab_tick = Tuning.BRUTE_GRAB_TICK
			target.take_damage(1, global_position, true)
		# Immortal hero: let go after a while, or a test run ends here.
		if Debug.god_mode and _grab_time >= Tuning.BRUTE_GOD_RELEASE:
			_release_grab()
			_grab_cd = Tuning.BRUTE_GRAB_COOLDOWN
		return

	_grab_cd = maxf(_grab_cd - delta, 0.0)
	var speed: float = Tuning.BRUTE_SPEED
	var to_target: Vector2 = target.global_position - global_position
	var reach: bool = absf(to_target.x) <= Tuning.BRUTE_GRAB_RANGE \
		and absf(to_target.y) <= Tuning.BRUTE_GRAB_DEPTH \
		and signf(to_target.x) == _face
	if reach and _grab_cd <= 0.0 and target.has_method("grabbed_by") \
			and target.grabbed_by(self):
		_grabbing = true
		_grab_time = 0.0
		_grab_tick = Tuning.BRUTE_GRAB_TICK * 0.5
		Sfx.play(&"brute_grab", global_position)
		return
	velocity.x = signf(to_target.x) * speed if absf(to_target.x) > Tuning.BRUTE_GRAB_RANGE * 0.6 else 0.0
	if absf(to_target.x) > Tuning.BRUTE_GRAB_RANGE * 0.6:
		_wish_speed = speed
	if free:
		var goal: float = clampf(to_target.y / 40.0, -1.0, 1.0) * speed * 0.6
		velocity.y = move_toward(velocity.y, goal, speed * 4.0 * delta)


func _release_grab() -> void:
	if _grabbing and target != null and target.has_method("release_grab"):
		target.release_grab(self)
	_grabbing = false


## Close on the player's depth, but smoothly and never exactly.
##
## Setting the vertical speed outright made a crowd snap onto the player's line
## and stay glued there, which read as teleporting rather than walking. Easing
## into the speed gives it weight, and the per-enemy offset stops thirty bodies
## from converging into one row.
func _track_depth(speed: float) -> void:
	var wanted: float = target.global_position.y + _depth_offset - global_position.y
	var goal: float = 0.0
	if absf(wanted) > 6.0:
		goal = clampf(wanted / 40.0, -1.0, 1.0) * speed
	velocity.y = move_toward(velocity.y, goal,
		speed * 4.0 * get_physics_process_delta_time())


func _draw() -> void:
	# A drawn character replaces the box entirely. Leaving the box behind the
	# sprite showed as a coloured slab around the legs.
	if Debug.show_strike_zone and kind == Kind.RUSHER and _attack_timer > 0.0:
		var cx: float = _facing() * Tuning.rusher_strike_forward
		var feet: float = SIZE.y * 0.5
		var zone := Rect2(cx - Tuning.rusher_strike_width * 0.5,
			feet - Tuning.rusher_strike_depth,
			Tuning.rusher_strike_width, Tuning.rusher_strike_depth * 2.0)
		var zc := Color(1.0, 0.15, 0.1, 0.55 if _attack_hit_done else 0.25)
		draw_rect(zone, zc)
		draw_rect(zone, Color(1.0, 0.15, 0.1, 0.9), false, 2.0)
	if _sprite != null and _sprite.visible:
		return
	var base := Color(0.62, 0.30, 0.28) if kind == Kind.RUSHER else Color(0.40, 0.34, 0.52)
	if kind == Kind.BRUTE:
		# Box fallback: skin-coloured body, grey plate on the facing side.
		base = Color(0.80, 0.58, 0.45)
		var big := SIZE * 1.6
		draw_rect(Rect2(Vector2(-big.x * 0.5, SIZE.y * 0.5 - big.y), big),
			base.lerp(Color(1.0, 0.96, 0.92), _flash))
		var plate_x: float = 0.0 if _face > 0.0 else -big.x * 0.5
		draw_rect(Rect2(Vector2(plate_x, SIZE.y * 0.5 - big.y + 10.0),
			Vector2(big.x * 0.5, big.y - 24.0)), Color(0.55, 0.58, 0.62))
		return
	var col := base.lerp(Color(1.0, 0.96, 0.92), _flash)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), col)
	draw_rect(Rect2(-SIZE * 0.5, SIZE), Color(0.10, 0.11, 0.14), false, 3.0)
	# equipment marker, so the two roles read apart at a glance
	if kind == Kind.RUSHER:
		draw_rect(Rect2(Vector2(-4, -SIZE.y * 0.5 - 10), Vector2(8, 10)),
			Color(0.85, 0.85, 0.9))
	else:
		draw_line(Vector2(-16, -14), Vector2(16, -22), Color(0.85, 0.85, 0.9), 4.0)
