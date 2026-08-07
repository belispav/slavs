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
