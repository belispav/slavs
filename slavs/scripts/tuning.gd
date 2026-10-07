extends Node

## Every gameplay constant lives here (CLAUDE.md working rule 6).
## Controls are NOT here — they live in ControlConfig / control_config.tres.

# --- Player movement ---
const GRAVITY: float = 2400.0
const MAX_FALL_SPEED: float = 1700.0
const RUN_SPEED: float = 420.0
const GROUND_ACCEL: float = 4200.0
const GROUND_DECEL: float = 5200.0
const AIR_ACCEL: float = 1900.0
const JUMP_VELOCITY: float = -900.0   # gives ~168 px of jump height
const COYOTE_TIME: float = 0.10
## How long a jump gesture is remembered if the character is not on the ground
## yet. Without this, a flick made a fraction of a second before landing is
## silently thrown away and reads as "the game ignored me".
const JUMP_BUFFER: float = 0.14

# --- Player art ---
## Where the player's frames live.
##
## 2026-10-02: switched to the PixelLab hero (generated, not rendered - see
## ref/candidates/pixellab/). The 3D-rendered hero is untouched in
## res://art/run_px; to go back, point these two at run_px / idle_px, set
## PLAYER_ANIM_FPS back to 30, PLAYER_ART_FACES_LEFT back to true and
## PLAYER_SPRITE_SCALE back to 1.0.
const PLAYER_ART_DIR: String = "res://art/hero_pl_run"
## Standing pose. Optional: without it the run cycle is held on its most
## upright frame, which is better than nothing but still a walking pose.
## The PixelLab hero's is one frame (its east-facing rotation), padded onto
## the run's 96x96 canvas with the feet on the same row.
const PLAYER_IDLE_ART_DIR: String = "res://art/hero_pl_idle"
## Chosen so one stride lasts as long as the old hero's: 17 frames at 30 fps
## = 0.57 s; the PixelLab run has 8 frames, so 14 fps = 0.57 s. At 30 it
## would read as running twice as fast as the character actually moves.
const PLAYER_ANIM_FPS: float = 14.0

## Thrower art. Three folders, one per state, rendered by
## tools/render_enemy.ps1 from a single fit - see PRIKAZY.md.
## Empty folders are not an error: the enemy falls back to the coloured box,
## the same way the player does.
##
## 2026-10-03: the gunman is the PixelLab one now (round spiked helmet, long
## dark blue coat, black boots - Pavel's design; no turban). The 3D render is
## untouched in gunman_*_px; to go back, point these three there, set
## THROWER_SPRITE_SCALE to ENEMY_SPRITE_SCALE and THROWER_ANIM_FPS /
## THROWER_FIRE_FPS to ENEMY_ANIM_FPS. The idle is a single frame (the east
## rotation) - no idle clip was generated yet, to save a credit.
const THROWER_IDLE_ART_DIR: String = "res://art/gunman_pl_idle"
const THROWER_WALK_ART_DIR: String = "res://art/gunman_pl_walk"
const THROWER_FIRE_ART_DIR: String = "res://art/gunman_pl_fire"
## PixelLab clips are 8-9 frames: 10 fps for the walk like the rusher's.
const THROWER_ANIM_FPS: float = 10.0
## Fire: 9 frames (raise, aim, flash on frame 5, recoil, lower) at 8 fps.
const THROWER_FIRE_FPS: float = 8.0
## How long the fire clip holds the gunman in place = 9 frames / 8 fps.
const THROWER_FIRE_TIME: float = 9.0 / THROWER_FIRE_FPS
## From the clip's start to the muzzle flash (frame 5 of 0-8) - the shot
## leaves then.
const THROWER_SHOT_DELAY: float = 5.0 / THROWER_FIRE_FPS
## Where the barrel's mouth is, in world units from the gunman's feet,
## measured on the flash frame: ~30 art px ahead of the body and ~52 above
## the feet, times the 2x scale.
const THROWER_MUZZLE_FORWARD: float = 60.0
const THROWER_MUZZLE_HEIGHT: float = 104.0
## The shot is aimed this far above the player's origin (his box centre), at
## the chest rather than the belt.
const THROWER_AIM_RAISE: float = 30.0

## Rusher art. Four folders instead of the thrower's three - see PRIKAZY.md's
## ZBRANE section for how they get filled.
##
## The idle is deliberately split in two. "Looking around" (IDLE) is right for
## an enemy that has not noticed the player yet; once it has closed in and is
## between swings it should be watching the player, not glancing around.
## Using the same "looking around" clip for both is what read wrong on the
## gunman, who is already firing while playing an idle that looks unaware -
## noted in CLAUDE.md, not fixed there yet. Fixed here first, on the enemy
## that does not exist as art yet, before it gets built the same way twice.
##
## 2026-10-02: the rusher is the PixelLab one now (helmet, spiked mace - no
## turban, per the content rule). The 3D-rendered rusher is untouched in
## rusher_idle_px / rusher_ready_px / rusher_walk_px / rusher_attack_px; to go
## back, point these four there, RUSHER_SPRITE_SCALE to 1.0 and both RUSHER
## fps constants to ENEMY_ANIM_FPS. Frames are mirrored to face west on
## export, like every other enemy's.
const RUSHER_IDLE_ART_DIR: String = "res://art/rusher_pl_idle"
const RUSHER_IDLE_READY_ART_DIR: String = "res://art/rusher_pl_ready"
const RUSHER_WALK_ART_DIR: String = "res://art/rusher_pl_walk"
const RUSHER_ATTACK_ART_DIR: String = "res://art/rusher_pl_attack"
## The PixelLab clips have 4-12 frames, not the 19-39 the renderer made, so
## they play slower than ENEMY_ANIM_FPS or every cycle looks sped up.
const RUSHER_ANIM_FPS: float = 10.0
## The swing on its own. 6 fps with the wind-up and the strike held (see
## art/rusher_pl_attack/frames.gd) = ~1.7 s, Pavel's pick of three variants.
const RUSHER_ATTACK_FPS: float = 6.0

const ENEMY_ANIM_FPS: float = 30.0
## PIXEL ART, S = 1. Reverted 2026-08-13 after the S = 2 pass was seen on
## device: it works, but it stops the game being pixel art, and pixel art is
## what Slavs is. Do not raise S again without raising the style question with
## Pavel first, in those words - "this stops being pixel art" - because that is
## the part that got lost last time. See DIZAJN_pozadie_a_rozlisenie.md.
## Enemy renders that go with this: gunman -Height 162, rusher -Height 190.
const ENEMY_SPRITE_SCALE: float = 1.0
## Per kind since 2026-10-02, because the two kinds no longer share an art
## pipeline. Both are PixelLab now (rusher 2026-10-02, gunman 2026-10-03),
## pixel art shown at an INTEGER 2x like the hero (PLAYER_SPRITE_SCALE).
const THROWER_SPRITE_SCALE: float = 2.0
const RUSHER_SPRITE_SCALE: float = 2.0
## Below this speed the thrower is standing rather than walking. Not zero:
## the hold-your-distance logic keeps nudging, and a walk cycle that starts and
## stops every few frames reads as a twitch.
const ENEMY_WALK_SPEED_MIN: float = 12.0
## The sprites are rendered facing left.
## false for the PixelLab hero (generated facing east); the 3D render faced left.
const PLAYER_ART_FACES_LEFT: bool = false
## PIXEL ART, S = 1. Reverted 2026-08-13 after the S = 2 pass was seen on
## device: it works, but it stops the game being pixel art, and pixel art is
## what Slavs is. Do not raise S again without raising the style question with
## Pavel first, in those words - "this stops being pixel art" - because that is
## the part that got lost last time. See DIZAJN_pozadie_a_rozlisenie.md.
## Hero render that goes with this: -Height 162. The hitbox stays 54 px on purpose: a body narrower than the
## drawing is what "generous hitboxes favouring the player" means in practice.
##
## 2026-10-02, PixelLab hero: the art is 1x what PixelLab drew (~58 px tall
## body on a 96 px canvas), so it is shown at an INTEGER multiple - 2x puts it
## at roughly the old hero's 122 px. Integer only: 1.5x would draw some pixels
## one wide and some two wide, which is exactly the "uneven pixels" problem
## from 2026-08-13. Live via the debug panel (1x / 2x) - see
## player_sprite_scale below.
const PLAYER_SPRITE_SCALE: float = 2.0
## Live copy, flipped between 1.0 and 2.0 by the "HRDINA 2x" switch on the
## debug panel. player.gd re-fits the sprite, feet, muzzle and hurtbox when it
## changes.
var player_sprite_scale: float = PLAYER_SPRITE_SCALE
## Below this horizontal speed the run cycle stops and the sprite holds a frame.
const PLAYER_ANIM_MIN_SPEED: float = 20.0

# --- Weapon ---
const BULLET_SPEED: float = 1400.0
## Safety net only. Shots now end when they leave the screen, so this just has
## to be longer than any shot could plausibly stay in view.
const BULLET_LIFETIME: float = 6.0
const FIRE_INTERVAL: float = 0.09
const BULLET_POOL_SIZE: int = 96
const MUZZLE_DISTANCE: float = 34.0

# --- Thrown axe (2026-10-03) ---
## The hero's weapon: a hand-axe thrown along the aim that comes back like a
## boomerang (plan 3.4). Limited range is the point - it reaches rushers and,
## with a step forward, gunmen, and it cuts through a whole line twice (out
## and back). The next throw waits for the catch. Switch back to the old
## bullets with "SEKERA" on the debug panel.
const PLAYER_WEAPON_AXE: bool = true
## Live copy, flipped by the "SEKERA" switch on the debug panel.
var player_weapon_axe: bool = PLAYER_WEAPON_AXE
## How far the axe flies before it turns round, in world units. The rusher's
## reach is 100, so even the slider's minimum outranges him.
const AXE_RANGE: float = 350.0
var axe_range: float = AXE_RANGE
## Outward speed, world units / s. Was 1100 - too fast to follow on device
## (Pavel 2026-10-03); live on the panel ("rychlost sekery").
const AXE_SPEED: float = 650.0
var axe_speed: float = AXE_SPEED
## The way back is this much faster than the way out, so the wait for the
## catch stays short even with a slow, readable throw.
## The way BACK is faster than the way out (x the out speed). 2026-10-07: 1.5.
const AXE_RETURN_FACTOR: float = 1.5
## Pavel 2026-10-07: the axe hurts only on the way OUT; on the way back it is
## half transparent, harmless and 50 % faster. Set true for a future "boomerang"
## upgrade (a returning axe that also cuts); it still never pushes.
const AXE_RETURN_HURTS: bool = false
const AXE_RETURN_ALPHA: float = 0.5
const AXE_SPIN: float = 22.0             # radians / s
const AXE_HIT_RADIUS: float = 20.0       # Pavel 2026-10-07 tested 20 (was 30)
var axe_hit_radius: float = AXE_HIT_RADIUS   # live from the panel
const AXE_CATCH_RADIUS: float = 28.0
## Safety net: if the hero keeps running away from his own axe, it is
## caught anyway after this long instead of chasing him forever.
const AXE_MAX_RETURN_TIME: float = 1.5
## Hits per pass. 1 = an enemy passed through out AND back takes 2.
const AXE_DAMAGE: int = 1
const AXE_TEXTURE: String = "res://art/axe_thrown/axe.png"
## Throw clip: frames listed in art/hero_pl_axe_throw/frames.gd, played at
## AXE_THROW_FPS; the axe leaves the hand on AXE_RELEASE_FRAME (index into
## that list - 5 is the frame where the arm is fully forward).
const PLAYER_AXE_IDLE_ART_DIR: String = "res://art/hero_pl_axe_idle"
const PLAYER_AXE_RUN_ART_DIR: String = "res://art/hero_pl_axe_run"
const PLAYER_AXE_THROW_ART_DIR: String = "res://art/hero_pl_axe_throw"
const AXE_THROW_FPS: float = 14.0
const AXE_RELEASE_FRAME: int = 5
## Share of normal walking speed while the throw clip plays (the clip is a standing
## pose; full speed looked like sliding). 0 = rooted: PICKED by Pavel on device
## 2026-10-05 (a feature - you choose the moment to throw). Later weapons (spells)
## will need an attack animation tied to movement; the axe is fine as is.
const THROW_MOVE_FACTOR: float = 0.0
var throw_move_factor: float = THROW_MOVE_FACTOR
## Speed of the throw's wind-up (the standing part before the axe leaves the hand),
## 1.0 = as drawn. Faster = a shorter moment where the hero must stand (a feature:
## he has to pick the moment of the throw). The follow-through stays 1x.
## 3.0 picked by Pavel on device 2026-10-05; idea: start the game lower (1.0) and
## let the hero level it up.
const THROW_WINDUP_SPEED: float = 3.0
var throw_windup_speed: float = THROW_WINDUP_SPEED

# --- Hit / death effects (2026-10-03, fx.gd) ---
## Pixel particles per event. Code-drawn placeholders for trying the
## mechanic; final look may become PixelLab clips later.
const FX_BLOOD_HIT: int = 8
const FX_BLOOD_DEATH: int = 30
const FX_WOOD_HIT: int = 6
const FX_WOOD_BREAK: int = 30
## The hero's own blood when something hits him.
const FX_BLOOD_PLAYER: int = 14
## How long blood/splinters lie on the ground before they are gone (s).
const FX_STAIN_TIME: float = 3.0
var fx_stain_time: float = FX_STAIN_TIME
var fx_enabled: bool = true

# --- Sounds (2026-10-04, sfx.gd) ---
## Chance that a rusher shouts when it starts a swing.
const RUSHER_SHOUT_CHANCE: float = 0.4
## Chance that a dying enemy cries out (on top of the generic death sound).
const ENEMY_DEATH_VOICE_CHANCE: float = 0.3
## Random enemy barks: one enemy on screen says something every N seconds,
## N random between these two. Live on the panel ("ako casto hovoria...").
const ENEMY_BARK_MIN: float = 6.0
const ENEMY_BARK_MAX: float = 12.0
var enemy_bark_every: float = ENEMY_BARK_MIN
## Hero barks: while there is a fight, every N seconds (random in range),
## plus this chance on every kill.
const HERO_BARK_MIN: float = 12.0
const HERO_BARK_MAX: float = 22.0
const HERO_BARK_ON_KILL: float = 0.08

# --- Vibration (2026-10-03) ---
## Phone buzz when the HERO is hit, in milliseconds. Pavel on device: a buzz
## on kills and barrel bursts felt odd; it belongs to taking a hit. A longer
## buzz also feels stronger - short pulses never reach the motor's full
## strength. Needs the VIBRATE permission in the Android export preset.
const VIBRATE_PLAYER_HIT_MS: int = 180
var vibrate_player_hit_ms: float = VIBRATE_PLAYER_HIT_MS
## Events closer together than this are dropped (s).
const VIBRATE_MIN_GAP: float = 0.08
var vibrate_enabled: bool = true
## 0..1, passed to Android as the amplitude (1.0 = the motor's maximum;
## phones that cannot vary it ignore it and buzz at their fixed strength).
var vibrate_strength: float = 1.0

# --- Hit feel, work package 1 "Uder ma vahu" (2026-10-07) ---
## Every effect has a panel switch (fx_*) and a live strength; Pavel finds the
## value on the phone, then it is baked into the constants below.
## A1 hit-stop: the game runs at HITSTOP_SCALE speed for hitstop_ms on a hit
## by the hero's weapon (kills last HITSTOP_KILL_FACTOR times longer). A new
## stop is not allowed sooner than HITSTOP_MIN_GAP after the last one began
## (kills ignore the gap), so a crowd never makes the game stutter.
const HITSTOP_MS: float = 40.0
const HITSTOP_KILL_FACTOR: float = 1.8
const HITSTOP_SCALE: float = 0.02
const HITSTOP_MIN_GAP: float = 0.18
var fx_hitstop_on: bool = true
var hitstop_ms: float = HITSTOP_MS
## A2 full white flash of the victim (game-time seconds, so it also holds
## through the hit-stop).
const HIT_WHITE_MS: float = 40.0
var fx_white_on: bool = true
var hit_white_ms: float = HIT_WHITE_MS
## A3 screen shake on the hero's weapon hits (world units; the cauldron blast
## uses 14). Panel value is a multiplier.
const SHAKE_HIT: float = 2.5
const SHAKE_KILL: float = 5.0
var fx_shake_on: bool = true
var shake_strength: float = 1.0
## A4 small camera kick along the weapon's travel (world units, decays with
## CAM_KICK_DECAY per second). Panel value is a multiplier.
const KICK_HIT: float = 5.0
const KICK_KILL: float = 9.0
const CAM_KICK_DECAY: float = 14.0
var fx_kick_on: bool = true
var kick_strength: float = 1.0
## E1 short phone buzz when the hero's weapon hits (kills x1.5 longer).
const VIBRATE_AXE_HIT_MS: float = 30.0
const VIBRATE_AXE_AMP: float = 0.6
var vibrate_axe_on: bool = true
var vibrate_axe_ms: float = VIBRATE_AXE_HIT_MS

# --- Explosive cauldron (2026-10-04, cauldron.gd) ---
const CAULDRON_ART_DIR: String = "res://art/cauldron_pl"
const CAULDRON_SPRITE_SCALE: float = 2.0
## Hits to light the fuse (axe out + back = 2 per throw).
const CAULDRON_HP: int = 6
## Seconds from the last hit to the bang. Live on the panel.
const CAULDRON_FUSE: float = 5.0
var cauldron_fuse: float = CAULDRON_FUSE
## A cauldron lit by a neighbour's blast goes off this soon after.
const CAULDRON_CHAIN_FUSE: float = 0.25
## Blast radius in world units. Depth (Y) counts double, so on the 2.5D field
## the blast is an ellipse flat like the ground, not a circle up the screen.
const CAULDRON_RADIUS: float = 220.0
var cauldron_radius: float = CAULDRON_RADIUS
## Damage to every enemy in the radius. 10 = every enemy so far dies; the
## armoured brute's armour does not stop it.
const CAULDRON_DAMAGE: int = 10
## The blast hurts the hero too if he stands in it (1 life). Off = only
## enemies. Live on the panel.
var cauldron_hurts_player: bool = true
## The whistle climbs this much in pitch over the fuse (1.0 = an octave).
const CAULDRON_WHISTLE_RISE: float = 1.2
## Hit area and foot blocking, from the art: the pot is ~52 x 52 at 2x
## ~104 wide; blocking derived like the barrel's (see BARREL_BLOCK_WIDTH).
const CAULDRON_HIT_SIZE: Vector2 = Vector2(100.0, 100.0)
const CAULDRON_BLOCK_WIDTH: float = 150.0
## Where they stand relative to the hero's feet at each (re)placement.
const CAULDRON_OFFSETS: Array[Vector2] = [
	Vector2(480.0, 140.0), Vector2(1050.0, -120.0),
]

# --- Breakable barrel (2026-10-03) ---
const BARREL_ART_DIR: String = "res://art/barrel_pl"
## 6 since 2026-10-03 (was 3): the returning axe hits twice per throw.
const BARREL_HP: int = 6
## Integer like every PixelLab sprite - 2x matches the hero.
const BARREL_SPRITE_SCALE: float = 2.0
## Slowed from 12 so the burst can be seen mid-fight (Pavel missed it).
const BARREL_BREAK_FPS: float = 9.0
## Hit area in world units, standing on the barrel's feet. The drawn barrel
## is about 48 x 64 at 2x; the box is a little bigger, in the player's favour.
const BARREL_HIT_SIZE: Vector2 = Vector2(60.0, 76.0)
## Where the barrels stand, relative to the hero's feet at the moment they
## are (re)placed: at the start, after every death, and on the panel button.
## Ahead of him on the right (where the thumb does not cover them), spread
## over the field's depth. Clamped to the walkable band.
const BARREL_OFFSETS: Array[Vector2] = [
	Vector2(300.0, 0.0), Vector2(420.0, -150.0),
	Vector2(950.0, 90.0), Vector2(1150.0, -30.0),
]
## Kept off the very edge of the walkable band so a barrel never stands on
## the palisade line or in the river.
const BARREL_EDGE_INSET: float = 30.0
## The wall: BARREL_WALL_COUNT barrels side by side along the depth (Y),
## BARREL_WALL_SPACING apart, centred on the hero's row, BARREL_WALL_X ahead
## of him - an obstacle to break through rather than step round (Pavel
## 2026-10-03: one barrel is just stepped round). Rebuilt with the others
## after every death. It does NOT span the whole field (that is ~970 deep);
## six barrels edge to edge are ~240.
const BARREL_WALL_COUNT: int = 6
const BARREL_WALL_X: float = 600.0
const BARREL_WALL_SPACING: float = 40.0
## How far, in depth (Y), a barrel blocks the hero's FEET either side of its
## own feet. The field is 2.5D: blocking has to compare where the two stand,
## not whether the drawings overlap. Raised automatically inside the wall so
## neighbours leave no gap to slip through.
const BARREL_BLOCK_DEPTH: float = 26.0
## How wide the blocking strip is, in X. Measured 2026-10-03 from the art, not
## guessed: the drawn barrel is 48 wide (24 each side of its centre), and the
## hero's front edge reaches ~44 world units past his centre (legs/axe, run
## and idle clips) while his collision box is only 15. For a ~6 unit gap
## between his front and the barrel: centres stop 24 + 6 + 44 = 74 apart,
## minus his box's 15 = 59 each side -> 118. Was 40, which let him walk ~33
## units into the drawing. Live on the panel ("sud: odstup postavy").
const BARREL_BLOCK_WIDTH: float = 118.0
var barrel_block_width: float = BARREL_BLOCK_WIDTH

## Where on the body a shot leaves from, as a fraction of the drawing's height
## measured up from the feet. The collision box is 54 units tall while the
## drawing is over twice that, so firing from the box's centre put the muzzle at
## ankle height - shots appeared to come out of the character's feet, which
## reads as the aim being wrong even when it is not.
## 0.58 measured on device: 0.62 put the muzzle just above the hands.
const MUZZLE_HEIGHT_FRACTION: float = 0.58

## Used when no sprite has been rendered yet and the grey box is drawn instead.
const MUZZLE_HEIGHT_FALLBACK: float = 18.0

## The player's hurt area, as fractions of the DRAWING rather than of the
## collision box.
##
## The collision box is 54 units tall and the drawing is over twice that, so a
## hurtbox sized from the box covered the hips and nothing else - shots passed
## through the chest and head with no effect, which reads as the game not
## registering hits.
##
## Still deliberately smaller than the picture. Narrow, because arms swing wide
## and being hit by the shadow of an elbow is not what design pillar 1 means by
## favouring the player.
const PLAYER_HURT_HEIGHT_FRACTION: float = 0.72
const PLAYER_HURT_WIDTH: float = 24.0
## Live, so the top/bottom margin can be felt out on the device instead of
## computed from a still frame. Measured 2026-08-10: the margins ARE
## symmetric to within about 1 px (~16-17 px each side of a 121 px body,
## both from the worst-case frame across the whole run cycle and from the
## resting frame alone) - if it still reads uneven on the phone, drag this
## up to shrink both margins evenly rather than guessing at the constant.
var player_hurt_height_fraction: float = PLAYER_HURT_HEIGHT_FRACTION

## Same problem as the player's, on the enemies: the collision box (SIZE,
## 30x52) is far shorter than either kind's drawn sprite (gunman ~162,
## rusher ~190 world units tall), so a hurtbox sized from the box only
## covers the legs - shots pass through the chest and head. Diagnosed
## 2026-08-13, fixed 2026-09-15 using the same fix as the player's:
## fraction of the DRAWN height, not of the collision box.
const ENEMY_HURT_HEIGHT_FRACTION: float = 0.72
const ENEMY_HURT_WIDTH: float = 24.0     # same precedent as PLAYER_HURT_WIDTH
## Live, same reason as player_hurt_height_fraction above.
var enemy_hurt_height_fraction: float = ENEMY_HURT_HEIGHT_FRACTION

# --- Player survivability ---
const PLAYER_MAX_HP: int = 5
const PLAYER_IFRAMES: float = 0.9     # invulnerable window after taking a hit
## Longer window after dying, so getting up in the middle of a crowd is not
## immediately fatal again.
const PLAYER_REVIVE_IFRAMES: float = 2.0
## What a hit FROM EACH ENEMY KIND does to the hero (Pavel 2026-10-06: the hop
## belongs to the rusher only; every enemy gets its own hit effect in config,
## later maybe slow or poison). Vector2.ZERO = no knockback.
## T33 (Pavel 2026-10-07) PUSH ("odhodenie"), both ways. A hit moves the victim a
## set distance (px) along the direction of the attack, over KNOCKBACK_TIME
## seconds (speed falls linearly to zero), stopped by solid bodies and the field
## edge. The old per-kind velocity hop (RUSHER_/THROWER_/BRUTE_HIT_KNOCKBACK, T27)
## is gone; only the cauldron blast above still uses the old velocity hop.
## Hero hit by a rusher's club: far (a heavy blow). Hero hit by a gunman's bullet:
## short. Brute: none, it only grabs. Enemies hit by the hero's axe: all pushed
## the same, except the brute (too big). Barrels and cauldrons are not pushed
## (open idea). The axe's way BACK counts as a hit too (factor 0 = no push).
const KNOCKBACK_TIME: float = 0.4
var knockback_time: float = KNOCKBACK_TIME
## Depth (screen Y) part of a push is scaled by this, the ground is foreshortened.
const KNOCKBACK_Y_FACTOR: float = 0.6
const RUSHER_PUSH_DIST: float = 90.0
var rusher_push: float = RUSHER_PUSH_DIST
const THROWER_PUSH_DIST: float = 35.0
var thrower_push: float = THROWER_PUSH_DIST
const AXE_PUSH_DIST: float = 70.0
var axe_push: float = AXE_PUSH_DIST
## A cauldron blast pushes the hero away from the centre (2026-10-07; the old
## velocity hop PLAYER_KNOCKBACK was only ~15 px and is gone).
const CAULDRON_PUSH_DIST: float = 140.0
var cauldron_push: float = CAULDRON_PUSH_DIST
## The hero's plain bullets (the panel can switch the axe off) push a little.
const BULLET_PUSH_DIST: float = 20.0

## The displacement for a hit travelling along `dir`: `dist` px, depth part
## foreshortened. ZERO for no direction or no distance.
static func push_vector(dir: Vector2, dist: float) -> Vector2:
	var d := Vector2(dir.x, dir.y * KNOCKBACK_Y_FACTOR)
	if dist <= 0.0 or d.length_squared() < 0.0001:
		return Vector2.ZERO
	return d.normalized() * dist

## Walking round obstacles (T28, 2026-10-06). An enemy that wants to approach
## but has moved less than DETOUR_STUCK_FRACTION of its wished speed for
## DETOUR_STUCK_TIME seconds is stuck behind something (a barrel wall) and picks
## ONE direction along Y. It keeps it until it can step towards the hero in X
## again for DETOUR_CLEAR_TIME seconds, or reaches the edge of the field (then
## it turns the other way). DETOUR_HOLD keeps the Y direction a moment longer so
## it does not turn straight back into the obstacle. DETOUR_Y_FACTOR scales the
## sideways speed against the wished speed.
const DETOUR_STUCK_TIME: float = 0.35
const DETOUR_STUCK_FRACTION: float = 0.3
const DETOUR_CLEAR_TIME: float = 0.25
const DETOUR_HOLD: float = 0.6
const DETOUR_Y_FACTOR: float = 0.7

# --- Enemies ---
const ENEMY_POOL_SIZE: int = 64
const ENEMY_COUNT_RANGE: float = 2200.0   # only enemies this close count for the cap
const ENEMY_MAX_ALIVE: int = 34       # design pillar: overwhelming numbers
const ENEMY_GRAVITY: float = 2200.0
const ENEMY_CONTACT_DAMAGE: int = 1

## How far from the player a rusher stops to swing, not to touch. 26 was
## "pressed against the player", left over from when the attack WAS the
## contact. Now that a swing lands the hit (see RUSHER_ATTACK_* below), the
## stopping distance reads as weapon reach instead.
##
## 100, measured on device 2026-08-10 against the full-length attack
## animation (the fix in enemy.gd's _attack_anim_duration) - the 70 placeholder
## and the 100-120 in-between were both judged against a swing that was being
## cut short, which is why this took two passes to settle.
const RUSHER_MELEE_RANGE: float = 100.0
var rusher_melee_range: float = RUSHER_MELEE_RANGE

## T16 (2026-10-06): a rusher that has stopped to fight stays stopped until the
## player is this many times RUSHER_MELEE_RANGE away. Without the gap, a player
## drifting on Y around exactly the range made the rusher stop/walk/stop every
## frame, and the clip flickered walk <-> idle_ready. Also the reach of a
## standing rusher's swing (range 100 -> up to 120 with 1.2).
const RUSHER_MELEE_LEAVE_FACTOR: float = 1.2
## A rusher's walk clip starts only above this speed and ends below
## ENEMY_WALK_SPEED_MIN (12): two thresholds, so the clip does not flip on
## every small speed change. T16.
const RUSHER_WALK_START_SPEED: float = 40.0

## How far into the swing the club actually connects, as a fraction of the
## attack animation. The range is re-checked at that instant, so this is the
## dodge window: everything before it can be stepped out of.
##
## 0.45 is a STARTING POINT, not a measurement. The real answer is wherever the
## club is furthest forward in the Slash clip, and CLAUDE.md already records
## that this particular swing travels out to the SIDE rather than into the
## player - so watch the render next to the hero and drag the slider, do not
## trust this number (METHOD rule 2).
##
## 2026-10-02, PixelLab swing: the mace comes down on frame 7 of 10, so the
## hit is set to 0.70. Still a starting point - the slider has the last word.
const RUSHER_ATTACK_HIT_AT: float = 0.70
var rusher_attack_hit_at: float = RUSHER_ATTACK_HIT_AT

## STRIKE ZONE (T29, 2026-10-06; circle since the phone test the same day).
## At the hit moment (RUSHER_ATTACK_HIT_AT) the club lands at a point
## STRIKE_FORWARD px in front of the rusher's origin and STRIKE_HEIGHT px above
## its feet (the mace head in the PixelLab swing is ~50 px above the feet).
## Values 40 / 50 / 40 picked by Pavel on the phone 2026-10-06. The
## zone is a CIRCLE of STRIKE_RADIUS around that point, in screen space. The
## hero is hit if his hurt rectangle (PLAYER_HURT_WIDTH wide, hung from his
## feet, see Player.hurt_rect) touches the circle. The rusher stops to swing as
## soon as the hero touches the circle (and stays stopped while he is within
## RUSHER_MELEE_LEAVE_FACTOR x the radius). All three live on the panel.
const RUSHER_STRIKE_FORWARD: float = 40.0
const RUSHER_STRIKE_RADIUS: float = 40.0
const RUSHER_STRIKE_HEIGHT: float = 50.0
var rusher_strike_forward: float = RUSHER_STRIKE_FORWARD
var rusher_strike_radius: float = RUSHER_STRIKE_RADIUS
var rusher_strike_height: float = RUSHER_STRIKE_HEIGHT

## How close two enemies may get before they push each other apart, in world
## units. Rushers all head for the same point - the player - so without this
## they arrive as one pile of overlapping bodies. Throwers barely need it; they
## already spread by holding different distances.
##
## Deliberately smaller than the drawn body: enemies SHOULD crowd and overlap a
## little, per design pillar 1. What this stops is them occupying one spot.
const ENEMY_SEPARATION: float = 46.0
var enemy_separation: float = ENEMY_SEPARATION

## T22 SOLID BODIES (Pavel 2026-10-06). Hero and enemies cannot walk through each
## other (hero <-> enemy and enemy <-> enemy), like barrels and cauldrons. The
## collision body of every character is only its FEET - a flat box hanging from
## the feet - because the camera is frontal and characters may walk behind each
## other (upper bodies may overlap, only the feet are solid). Replaces the soft
## push of main.gd _separate_enemies while on (that function is skipped).
## Off = old behaviour (soft push, nobody blocks anybody) - panel switch, for
## comparing and as an escape if a crowd of 30+ jams.
const SOLID_BODIES: bool = true
var solid_bodies: bool = SOLID_BODIES
## Footprint of one character: height = depth of the solid part (about 40 % of
## the 52-54 px body box; 54 = the whole old box), width across the feet.
## Also drives how far barrels and cauldrons block in depth (their strips are
## computed from this height, see barrel.gd _set_blocking).
const BODY_FEET_HEIGHT: float = 30.0
var body_feet_height: float = BODY_FEET_HEIGHT
const BODY_FEET_WIDTH: float = 60.0
## The width the barrel/cauldron blocking strips were measured with (BARREL_BLOCK_WIDTH).
const BODY_FEET_REF_WIDTH: float = 30.0
var body_feet_width: float = BODY_FEET_WIDTH

## T31 SHADOWS (Pavel 2026-10-06): flat ellipse on the ground under characters,
## barrels and cauldrons (shadow.gd). Strength 0 = off; scale multiplies every
## shadow's width. Width per object comes from its drawn size (SHADOW_WIDTH_*).
const SHADOW_ALPHA: float = 0.3
var shadow_alpha: float = SHADOW_ALPHA
const SHADOW_SCALE: float = 1.0
var shadow_scale: float = SHADOW_SCALE
## Shadow width as a fraction of a character's drawn height.
const SHADOW_WIDTH_PER_HEIGHT: float = 0.55
## Absolute z of every shadow: above the ground, its decorations and the blood
## stains, under every character. main.gd sets it from the ground's z.
var shadow_z: int = -100

## Hit points as hearts over the characters (hearts.gd): 0 = off,
## 1 = the hero and wounded enemies only, 2 = everybody.
var hearts_mode: int = 2

## How fast the foreground parallax strip (env_05_fg.png, main.gd's BG_LAYERS)
## scrolls relative to the ground it sits in front of. 1.0 would move with the
## ground like it was painted on it; > 1.0 reads as closer to the eye - see
## DIZAJN_pozadie_a_rozlisenie.md SS8 KROK 2.
##
## 1.3 is a starting guess, not a measurement - KROK 2's whole point is trying
## 1.15 / 1.3 / 1.5 on the device and letting Pavel pick, via the panel slider
## below (range 1.0-1.8, per the doc) rather than redeploying per guess.
const FG_PARALLAX_FACTOR: float = 1.3
var fg_parallax_factor: float = FG_PARALLAX_FACTOR

## How fast everything BEHIND the ground scrolls - the sky layer and the
## valley layer under the ledge (main.gd's BG_LAYERS, every entry with a
## factor < 1).
##
## A multiplier on each layer's own factor, not an absolute speed: two layers
## back there at different distances would be collapsed onto one speed by a
## single absolute number. 1.0 = the literals in BG_LAYERS unchanged, 0.5 =
## half as fast as painted, 2.0 = twice.
##
## Range 0.1-3.0 on the panel. Pavel asked for this control 2026-08-15 (there
## was no way to feel out the parallax speed without a redeploy per guess);
## built 2026-09-14, and he picked 3.0 the same day. That 3x is already baked
## into the BG_LAYERS literals, which is why this sits at 1.0 again - the
## slider finds the number, the data stores it.
const BG_PARALLAX_SPEED: float = 1.0
var bg_parallax_speed: float = BG_PARALLAX_SPEED

## How many world units short of the picture's own measured edge - top AND
## bottom both, the same number - the character's feet stop. See
## player.gd's _move_free(): applied on top of whichever bound is active,
## the flat one or the per-column one.
##
## ADDED 2026-09-15: with the top edge now following env_08's real
## silhouette (main.gd's _walk_top_curve), the character could walk its
## feet right onto the measured line - which reads as standing IN the
## grass, not at its edge. Pavel on device: "postava je trochu prilis
## vysoko... budeme musiet zastavit par pixelov pred okrajom." The panel
## range is 0-60, a guess at how far "a few pixels" could mean, not a
## measurement.
##
## 20, picked on device 2026-09-15 ("idealny odstup vyzera byt okolo 20"),
## against both the top curve and the new bottom one. Same pattern as
## BG_PARALLAX_SPEED above: the slider found the number, so it is baked in
## here and the slider sits back at the value it now represents.
const WALK_EDGE_INSET: float = 20.0
var walk_edge_inset: float = WALK_EDGE_INSET
## The bottom edge only (Pavel 2026-10-06: the strip at the bottom was too wide,
## halved). The top keeps WALK_EDGE_INSET. Applies to the hero and to enemies.
const WALK_BOTTOM_INSET: float = 10.0
var walk_bottom_inset: float = WALK_BOTTOM_INSET

## The scene (Pavel 2026-10-05, ground pixen A): the walkable ground is exactly one
## screen tall (SCENE_FIELD_HEIGHT) and starts at picture row SCENE_GROUND_ROW (the
## first ground row of ground_pixen_a_top.json). Above it is the dynamic top strip
## (forest/sky), about one hero tall: the camera may scroll up until the strip is
## `scene_strip_height` tall on screen (so the hero's head meets the top edge when
## he stands on the back edge) and down until the strip is gone. Panel slider.
## The same camera rule is used when walking and in a frozen (FULL SCENE) screen;
## the only difference is that FULL SCENE also locks horizontal scrolling.
const SCENE_GROUND_ROW: float = 350.0
const SCENE_FIELD_HEIGHT: float = 720.0
const SCENE_STRIP_HEIGHT: float = 190.0
var scene_strip_height: float = SCENE_STRIP_HEIGHT


## Draw order for anything standing on the ground plane.
##
## The field is a flat picture seen from slightly above, so DEPTH IS Y: a body
## lower on the screen is nearer the camera and must be drawn in front. Without
## this, order came from the enemy pool, so whichever node happened to be
## earlier in the array covered the one in front of it - which Pavel spotted as
## enemies higher up the screen overlapping the ones below them, exactly
## backwards.
##
## Godot's own y_sort_enabled would do this too, but it interacts with the
## z_index = -1 the sprites carry (so the aim line draws over the body), and
## "it should sort" is not something worth guessing at again. This is explicit
## and can be read.
static func depth_z(world_y: float) -> int:
	return clampi(int(world_y), -4000, 4000)

## Enemies never move to the LEFT of the player. That is not a difficulty
## choice, it is forced by the hand: the left thumb covers the left third of
## the screen, so a threat arriving from there cannot be seen. Rushers used to
## run at the player, overshoot and turn back, which meant they spent half
## their time in exactly that blind area.
const ENEMY_KEEP_RIGHT_MARGIN: float = 8.0

## How far off the player's depth each enemy settles, in free movement. Without
## it a crowd converges onto one line and reads as a queue rather than a mob.
const ENEMY_DEPTH_SPREAD: float = 34.0

## How far behind the player an enemy may fall before it is recycled. Pavel
## 2026-10-05: enemies left behind off-screen must still exist and keep coming
## (he runs back and they are there), so this is only a pool-safety limit now.
## Far stragglers do not count against ENEMY_MAX_ALIVE (see Tuning.ENEMY_COUNT_RANGE).
const ENEMY_CULL_BEHIND: float = 4000.0

## A body walking toward you does not travel in a straight line. Each enemy
## drifts across its approach, at its own speed and phase, which is enough to
## stop a crowd looking like it is on rails.
const ENEMY_WEAVE_AMPLITUDE: float = 46.0
const ENEMY_WEAVE_SPEED: float = 1.6

## Rushers are chaff. One hit, large numbers — the point is mowing, not duelling.
##
## 262, measured on device 2026-08-04. The road there is worth keeping: guessed
## at 230, dropped to 46, raised to 437, settled at 262.
##
## The 46 was not a preference. It was tuning around dying constantly and being
## sent back to the start each time; once death cost health instead of the run,
## the same player asked for nearly ten times the speed. A number measured while
## something else is broken measures the other thing.
## 2 since 2026-10-03 (was 1): the returning axe hits once out and once back,
## so at 1 everything died like flies (Pavel).
const RUSHER_HP: int = 2
const RUSHER_SPEED: float = 262.0

## How far away, on the ground plane, an enemy notices the player and switches
## its idle from "unaware" to closing in. 640 = half the 1280-wide viewport -
## the point Pavel asked for when trying this concept on the rusher first.
## Live below, so it can be found on the device rather than guessed.
const ENEMY_DETECTION_RANGE: float = 640.0
var enemy_detection_range: float = ENEMY_DETECTION_RANGE

## How long a rusher waits between attacks once it has closed to melee range,
## and how long the attack animation holds before the ready idle returns.
##
## Pavel's correction 2026-08-07: a rusher pressed against the player and
## dealing damage on touch is a shove, not a swing - it does not match a
## character holding a club out in front of itself. The hit now lands when
## the swing triggers (enemy.gd's melee_hit signal), gated by
## RUSHER_MELEE_RANGE above instead of by the hurtbox touching. Landing it at
## the start of the swing rather than mid-animation is a placeholder - once
## the club render exists, watch it and move the timing to match, not before.
const RUSHER_ATTACK_INTERVAL: float = 0.9
const RUSHER_ATTACK_ANIM_TIME: float = 0.35

## Live multipliers, so speeds can be found on the device instead of guessed.
## The constants above stay the source of truth; once a value settles, it goes
## into the constant and the multiplier returns to 1.
var rusher_speed_scale: float = 1.0
var thrower_speed_scale: float = 1.0
## The stick has a speed ceiling that copying the thumb did not, so switching
## back to it reads as slower. Tunable rather than argued about.
var player_speed_scale: float = 1.0

## Throwers are the rare ones that force you to move. Slow, dodgeable shots:
## fast projectiles turned the game into a reflex test and killed the mowing.
## 1 since 2026-10-07 (Pavel; was 4, 2026-10-03: 2).
const THROWER_HP: int = 1
## BRUTE (2026-10-04, Pavel): slow, fat, armoured in FRONT only. The axe
## bounces off the plate (enemy.gd hit_from) and only hurts from behind -
## circle him so the returning axe takes his back. The cauldron's blast
## ignores the plate. He grabs the hero and does not let go: certain death
## for now, the others finish the job. All numbers are first guesses.
const BRUTE_IDLE_ART_DIR: String = "res://art/brute_pl_idle"
const BRUTE_WALK_ART_DIR: String = "res://art/brute_pl_walk"
const BRUTE_GRAB_ART_DIR: String = "res://art/brute_pl_grab"
const BRUTE_SPRITE_SCALE: float = 2.0
const BRUTE_ANIM_FPS: float = 8.0
## 1 since 2026-10-07 (Pavel; was 10 = one cauldron blast). The plate still
## deflects frontal hits, so one hit from behind kills him.
const BRUTE_HP: int = 1
const BRUTE_SPEED: float = 50.0
## How close (X) and how far off the hero's row (Y) he can grab.
const BRUTE_GRAB_RANGE: float = 80.0
const BRUTE_GRAB_DEPTH: float = 30.0
## Held hero loses one life this often (s).
const BRUTE_GRAB_TICK: float = 1.0
## Where the held hero is put, in front of the brute's centre.
const BRUTE_HOLD_DISTANCE: float = 56.0
## He needs this long (s) to turn round - the window to get behind him.
const BRUTE_TURN_TIME: float = 2.0
## God mode only: let go after this long, then wait before grabbing again.
const BRUTE_GOD_RELEASE: float = 2.0
const BRUTE_GRAB_COOLDOWN: float = 2.5
## One spawn in this many is a brute (if the cap allows).
const BRUTE_SPAWN_ONE_IN: int = 8

## 76, measured on device 2026-08-04. Slower than a rusher by roughly the same
## ratio as before, so the two roles still read apart at a glance.
const THROWER_SPEED: float = 76.0
const THROWER_KEEP_DISTANCE: float = 430.0
## Each thrower picks its own range within this much of the nominal one.
##
## With a single distance they all stop on the same line and stand in a heap,
## which reads as one enemy drawn several times rather than several enemies.
## Later this is where the difference between enemy types goes; for now a spread
## is enough to break the row up.
const THROWER_DISTANCE_SPREAD: float = 0.34
const THROWER_RANGE: float = 700.0
const THROWER_INTERVAL: float = 2.0
const THROWER_SHOT_SPEED: float = 330.0

# --- Spawning ---
const SPAWN_INTERVAL: float = 0.28
const SPAWN_MARGIN: float = 220.0     # how far off-screen enemies appear
const SPAWN_JITTER: float = 260.0
const THROWER_RATIO: float = 0.16

# --- World ---
const RESPAWN_Y: float = 1400.0       # falling below this respawns the player

# --- Collision layers ---
const LAYER_WORLD: int = 1
const LAYER_PLAYER: int = 2
const LAYER_TARGET: int = 4
const LAYER_ENEMY: int = 8
## Solid props the hero cannot walk through (barrels). Only the player masks it.
const LAYER_PROP: int = 16


## All the grounds the debug panel can switch between (Pavel 2026-10-05, "budem
## skusat"). Order = the order the panel button cycles through. "scene": true
## marks a one-screen ground (PixelLab pixen, 672x384 art px shown at 2x), which is
## only meant for SCENA BEZ SCROLLU - picking one turns that mode on by itself.
const GROUND_ORDER: Array = ["pixen_a"]
const GROUNDS := {
	"pixen_a": {"label": "PIXEN A: pokojna hlina", "scene": true,
		"tex": "res://art/ground_pixen_a.png", "top": "res://art/ground_pixen_a_top.json",
		"bottom": "res://art/ground_pixen_a_bottom.json"},
}
## Pavel 2026-10-05: A (calm PixelLab dirt) + walk-through objects won; the other
## grounds (pixen D/E/F, Nano Banana, PixelLab strip) were dropped from the game.
## Their files stay in art/ and their history is in _archiv/CLAUDE_historia.md.

## Walk-through ground objects (stones, pebbles, grass+moss patches cut from the
## PixelLab ground tile - art/ground_objects.png). Plain sprites, NO collision:
## unlike a barrel they never block anybody. Panel: "OBJEKTY NA ZEMI" + density.
## `decor_density` is objects per screen-sized area (1280x720). 20 is a guess.
var decor_density: float = 40.0
