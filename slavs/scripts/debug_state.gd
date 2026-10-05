extends Node

## Slavs - debug-only switches, set from the tuning panel (debug_overlay.gd).
##
## Separate from Tuning on purpose: Tuning holds gameplay constants that are
## measured on device and can end up in control_config.tres or in the shipped
## constants. Nothing here is ever allowed to ship or to touch
## control_config.tres - these exist so Pavel can look at one enemy type, or
## stop dying mid-look, while testing on the phone.

## --- Pavel's testing defaults, set 2026-08-13 on his ask ---------------------
##
## He was re-setting the same three switches by hand on every launch, which is
## how a testing session turns into panel-fiddling. These are DEFAULTS, not
## decisions: nothing here may ship, and the release checklist has to put
## god_mode back to false, music back to true and both caps back to
## Tuning.ENEMY_MAX_ALIVE.

## No damage reaches the player while true. Death, knockback and iframes are
## all skipped in player.gd - not just the health subtraction, or the
## knockback would still throw the character around while "immortal".
var god_mode: bool = true

## Draw the touch helpers (move zone, thumb anchors, aim line, rings). Off by
## default since 2026-10-03: they were tied to the panel being open, so they
## showed during normal play whenever the panel was left expanded.
var show_touches: bool = false

## Stops rushers being spawned. Enemies already on screen are despawned the
## moment this is switched on, so the effect is immediate instead of waiting
## for the current wave to die off.
var disable_rusher: bool = false

## Same for throwers.
var disable_thrower: bool = false

## Same for the brute (2026-10-04).
var disable_brute: bool = false

## How many of each kind may be alive at once, for testing - separate from
## Tuning.ENEMY_MAX_ALIVE, which stays the real design ceiling (34, per
## design pillar 1's "overwhelming numbers"). Watching one enemy's animation
## is impossible in a pile of thirty; these let the crowd be thinned instead
## of just switched off. Default is the full ceiling, so leaving the sliders
## alone changes nothing - drag down to a handful, or to 1 to watch a single
## enemy's full idle/walk/attack cycle in isolation.
## Now defaulted to 3 for Pavel's art-judging sessions - see the block above.
## The real ceiling for play is Tuning.ENEMY_MAX_ALIVE and it has not moved.
var max_rusher_alive: int = 3
var max_thrower_alive: int = 3
var max_brute_alive: int = 1

## Background filter: NEAREST (false) or LINEAR (true).
##
## The characters moved to S = 2 and are now smooth; env_03 did not, and is
## still MAGNIFIED ~1.5x on the phone, where Nearest gives uneven blocks - one
## asset pixel covering sometimes 1 and sometimes 2 device pixels. That is what
## reads as "the background is pixelated next to the characters".
##
## Nearest is the right filter for real pixel art. env_03 is not pixel art:
## 46 885 colours and a 2-3 px stroke, i.e. an imitation. So Linear is arguably
## correct for it - but softer, not sharper. Linear cannot add detail that is
## not in the file; only a new, higher-resolution background can (P1, KROK 3).
## This switch exists so the choice is made by looking, not by arguing.
var smooth_background: bool = false

## Draw env_04 (the fine-grained pixel-art background, generated 2026-08-13)
## instead of env_03. Both are 2816x1536 with the same layout, so this is a
## straight texture swap - the walkable band, the camera and the enemy spawns
## all stay exactly where they are.
##
## Here so the two can be compared IN MOTION on the phone. A still cannot show
## the one thing that actually matters about a background this dense: whether
## it shimmers while scrolling, and whether a crowd of enemies still reads
## against it (design pillar 1).
var alt_background: bool = false


## Set by the panel's "NOVE SUDY" button; main.gd stands every barrel up
## again in front of the hero and clears the flag.
var barrels_reset_requested: bool = false

## Set by the panel's RESET button; main.gd resets the whole run (field,
## hero, counters, props) and clears the flag.
var game_reset_requested: bool = false


## Simulates a NON-scrolling single-screen scene (Pavel 2026-10-05): the camera
## is fixed on picture rows Tuning.SCENE_TOP_ROW .. +720 (the size of one PixelLab
## 1376x768 image), and the hero walks only on the lower part of the screen,
## Tuning.scene_walk_depth tall. Panel: "SCENA BEZ SCROLLU".
var fixed_screen: bool = false
