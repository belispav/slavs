extends Node

## VOLYA - debug-only switches, set from the tuning panel (debug_overlay.gd).
##
## Separate from Tuning on purpose: Tuning holds gameplay constants that are
## measured on device and can end up in control_config.tres or in the shipped
## constants. Nothing here is ever allowed to ship or to touch
## control_config.tres - these exist so Pavel can look at one enemy type, or
## stop dying mid-look, while testing on the phone.

## No damage reaches the player while true. Death, knockback and iframes are
## all skipped in player.gd - not just the health subtraction, or the
## knockback would still throw the character around while "immortal".
var god_mode: bool = false

## Stops rushers being spawned. Enemies already on screen are despawned the
## moment this is switched on, so the effect is immediate instead of waiting
## for the current wave to die off.
var disable_rusher: bool = false

## Same for throwers.
var disable_thrower: bool = false

## How many of each kind may be alive at once, for testing - separate from
## Tuning.ENEMY_MAX_ALIVE, which stays the real design ceiling (34, per
## design pillar 1's "overwhelming numbers"). Watching one enemy's animation
## is impossible in a pile of thirty; these let the crowd be thinned instead
## of just switched off. Default is the full ceiling, so leaving the sliders
## alone changes nothing - drag down to a handful, or to 1 to watch a single
## enemy's full idle/walk/attack cycle in isolation.
var max_rusher_alive: int = 34
var max_thrower_alive: int = 34

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
