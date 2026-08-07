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
## Where the pixel pass writes the player's frames.
const PLAYER_ART_DIR: String = "res://art/run_px"
## Standing animation. Optional: without it the run cycle is held on its most
## upright frame, which is better than nothing but still a walking pose.
const PLAYER_IDLE_ART_DIR: String = "res://art/idle_px"
## The renderer produces every frame of the mocap. 30 was picked over 15 and 10
## by eye; both lower rates read as choppy on this run cycle.
const PLAYER_ANIM_FPS: float = 30.0

## Thrower art. Three folders, one per state, rendered by
## tools/render_enemy.ps1 from a single fit - see PRIKAZY.md.
## Empty folders are not an error: the enemy falls back to the coloured box,
## the same way the player does.
const THROWER_IDLE_ART_DIR: String = "res://art/gunman_idle_px"
const THROWER_WALK_ART_DIR: String = "res://art/gunman_walk_px"
const THROWER_FIRE_ART_DIR: String = "res://art/gunman_fire_px"

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
const RUSHER_IDLE_ART_DIR: String = "res://art/rusher_idle_px"
const RUSHER_IDLE_READY_ART_DIR: String = "res://art/rusher_ready_px"
const RUSHER_WALK_ART_DIR: String = "res://art/rusher_walk_px"
const RUSHER_ATTACK_ART_DIR: String = "res://art/rusher_attack_px"

const ENEMY_ANIM_FPS: float = 30.0
const ENEMY_SPRITE_SCALE: float = 1.0
## Below this speed the thrower is standing rather than walking. Not zero:
## the hold-your-distance logic keeps nudging, and a walk cycle that starts and
## stops every few frames reads as a twitch.
const ENEMY_WALK_SPEED_MIN: float = 12.0
## The sprites are rendered facing left.
const PLAYER_ART_FACES_LEFT: bool = true
## 1.0 = the rendered 96 px height. The hitbox stays 54 px on purpose: a body
## narrower than the drawing is what "generous hitboxes favouring the player"
## means in practice.
const PLAYER_SPRITE_SCALE: float = 1.0
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

# --- Player survivability ---
const PLAYER_MAX_HP: int = 5
const PLAYER_IFRAMES: float = 0.9     # invulnerable window after taking a hit
## Longer window after dying, so getting up in the middle of a crowd is not
## immediately fatal again.
const PLAYER_REVIVE_IFRAMES: float = 2.0
const PLAYER_KNOCKBACK: Vector2 = Vector2(240.0, -320.0)

# --- Enemies ---
const ENEMY_POOL_SIZE: int = 64
const ENEMY_MAX_ALIVE: int = 34       # design pillar: overwhelming numbers
const ENEMY_GRAVITY: float = 2200.0
const ENEMY_CONTACT_DAMAGE: int = 1

## How far from the player a rusher stops to swing, not to touch. 26 was
## "pressed against the player", left over from when the attack WAS the
## contact. Now that a swing lands the hit (see RUSHER_ATTACK_* below), the
## stopping distance has to read as weapon reach instead - Pavel's note
## 2026-08-07: it depends on how the club animation actually looks, so this
## stays a guess until it is measured against the render, not tuned by number.
## Live below so it can be found on the device.
const RUSHER_MELEE_RANGE: float = 70.0
var rusher_melee_range: float = RUSHER_MELEE_RANGE

## Enemies never move to the LEFT of the player. That is not a difficulty
## choice, it is forced by the hand: the left thumb covers the left third of
## the screen, so a threat arriving from there cannot be seen. Rushers used to
## run at the player, overshoot and turn back, which meant they spent half
## their time in exactly that blind area.
const ENEMY_KEEP_RIGHT_MARGIN: float = 8.0

## How far off the player's depth each enemy settles, in free movement. Without
## it a crowd converges onto one line and reads as a queue rather than a mob.
const ENEMY_DEPTH_SPREAD: float = 34.0

## How far behind the player an enemy may fall before it is recycled. Generous,
## so nothing vanishes while it is still on screen.
const ENEMY_CULL_BEHIND: float = 900.0

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
const RUSHER_HP: int = 1
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
const THROWER_HP: int = 2
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
