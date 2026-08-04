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
## The renderer produces every frame of the mocap. 30 was picked over 15 and 10
## by eye; both lower rates read as choppy on this run cycle.
const PLAYER_ANIM_FPS: float = 30.0
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
const BULLET_LIFETIME: float = 1.1
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

## How close a rusher presses before it stops. Pushing against the player IS
## its attack, so the gap is small.
const ENEMY_STOP_GAP: float = 26.0

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
## 437 measured on device 2026-08-04, and the road there is worth keeping. An
## earlier session set them to 46 — a fifth of this — but that was tuning around
## dying constantly and being returned to the start of the level each time. Once
## death cost health instead of the run, the same player asked for nearly ten
## times the speed. A number measured while something else is broken measures
## the other thing.
const RUSHER_HP: int = 1
const RUSHER_SPEED: float = 437.0

## Live multipliers, so speeds can be found on the device instead of guessed.
## The constants above stay the source of truth; once a value settles, it goes
## into the constant and the multiplier returns to 1.
var rusher_speed_scale: float = 1.0
var thrower_speed_scale: float = 1.0

## Throwers are the rare ones that force you to move. Slow, dodgeable shots:
## fast projectiles turned the game into a reflex test and killed the mowing.
const THROWER_HP: int = 2
## Confirmed unchanged on device 2026-08-04.
const THROWER_SPEED: float = 95.0
const THROWER_KEEP_DISTANCE: float = 430.0
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
