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

# --- World ---
const RESPAWN_Y: float = 1400.0       # falling below this respawns the player

# --- Collision layers ---
const LAYER_WORLD: int = 1
const LAYER_PLAYER: int = 2
const LAYER_TARGET: int = 4
