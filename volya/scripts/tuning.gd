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

# --- Weapon ---
const BULLET_SPEED: float = 1400.0
const BULLET_LIFETIME: float = 1.1
const FIRE_INTERVAL: float = 0.09
const BULLET_POOL_SIZE: int = 96
const MUZZLE_DISTANCE: float = 34.0

# --- Player survivability ---
const PLAYER_MAX_HP: int = 3
const PLAYER_IFRAMES: float = 0.9     # invulnerable window after taking a hit
const PLAYER_KNOCKBACK: Vector2 = Vector2(240.0, -320.0)

# --- Enemies ---
const ENEMY_POOL_SIZE: int = 48
const ENEMY_MAX_ALIVE: int = 26       # design pillar: 15-30 on screen
const ENEMY_GRAVITY: float = 2200.0
const ENEMY_CONTACT_DAMAGE: int = 1

const RUSHER_HP: int = 2
const RUSHER_SPEED: float = 230.0

const THROWER_HP: int = 2
const THROWER_SPEED: float = 95.0
const THROWER_KEEP_DISTANCE: float = 430.0
const THROWER_RANGE: float = 700.0
const THROWER_INTERVAL: float = 1.7
const THROWER_SHOT_SPEED: float = 620.0

# --- Spawning ---
const SPAWN_INTERVAL: float = 0.5
const SPAWN_MARGIN: float = 220.0     # how far off-screen enemies appear
const THROWER_RATIO: float = 0.3

# --- World ---
const RESPAWN_Y: float = 1400.0       # falling below this respawns the player

# --- Collision layers ---
const LAYER_WORLD: int = 1
const LAYER_PLAYER: int = 2
const LAYER_TARGET: int = 4
const LAYER_ENEMY: int = 8
