extends Node

## Sound effects and voice lines (autoload: Sfx), 2026-10-04.
##
## Every event is a FOLDER under res://audio/sfx/<event>/. Drop any number of
## .wav/.ogg/.mp3 files in it and one is picked at random each time, with a
## small random pitch shift so a sound repeated thirty times in a fight does
## not turn into a machine gun of the same sample. An empty or missing folder
## is silent, not an error - the game runs before the sounds exist.
##
## Two buses, created here so nothing in the project settings has to change:
## "Sfx" (shots, hits, wood) and "Voice" (shouts, "au", barks). Each has its
## own volume on the debug panel; voices matter for the story, so they must
## be balanced on their own.
##
## Voices are rationed: only one line at a time across the whole field
## (VOICE_GAP), or thirty enemies would talk over each other. Effects are
## rationed per event instead (MAX_SAME) - three gunshots at once read as a
## volley, ten read as noise.

const ROOT: String = "res://audio/sfx/"

## Which events are voices. Everything else is an effect.
const VOICE_EVENTS: Array[StringName] = [
	&"hero_hurt", &"hero_death", &"hero_bark",
	&"rusher_shout", &"enemy_bark", &"enemy_death_voice",
]

const SFX_POOL: int = 16
const VOICE_POOL: int = 4
## At most this many of one effect playing at once.
const MAX_SAME: int = 3
## Minimum time between two plays of the same effect (s). Pavel 2026-10-04:
## the axe passes through a row of barrels in a fraction of a second and the
## knocks chained into one rattle. Anything not listed uses DEFAULT_GAP.
const EVENT_GAP: Dictionary = {
	&"barrel_hit": 0.35,
	&"enemy_hit": 0.08,
}
const DEFAULT_GAP: float = 0.04
## Minimum gap between two voice lines anywhere on the field (s). The hero's
## own hurt cry ignores it - being hit must always answer.
const VOICE_GAP: float = 1.2
## Random pitch range: effects vary more than voices (a voice pitched too far
## stops sounding like the same person).
const SFX_PITCH: float = 0.25
const VOICE_PITCH: float = 0.03
## T32 (Pavel 2026-10-06): sounds must not sound mechanical. Besides the random
## pitch above, each play gets a slightly random volume: +-this many dB, a
## little, not much. Live on the debug panel (effects); voices keep a smaller
## constant spread.
const SFX_VOLUME_JITTER_DB: float = 2.5
const VOICE_VOLUME_JITTER_DB: float = 1.0

var enabled: bool = true
## Live copies of the spreads (panel sliders): pitch is +-fraction, volume +-dB.
var sfx_pitch: float = SFX_PITCH
var sfx_volume_jitter_db: float = SFX_VOLUME_JITTER_DB
var sfx_volume_db: float = 0.0
var voice_volume_db: float = 0.0

var _streams: Dictionary = {}       # event -> Array[AudioStream]
var _sfx: Array[AudioStreamPlayer2D] = []
var _voice: Array[AudioStreamPlayer2D] = []
var _next_sfx: int = 0
var _next_voice: int = 0
var _voice_cd: float = 0.0
var _last_play: Dictionary = {}     # event -> time (s) of its last play
var _sfx_bus: int = -1
var _voice_bus: int = -1


func _ready() -> void:
	# Keeps playing while the panel's FREEZE switch pauses the world (the hero's
	# own sounds must still be heard); see debug_overlay.gd.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sfx_bus = _make_bus(&"Sfx")
	_voice_bus = _make_bus(&"Voice")
	for i in SFX_POOL:
		_sfx.append(_make_player(&"Sfx"))
	for i in VOICE_POOL:
		_voice.append(_make_player(&"Voice"))
	_load_all()


func _process(delta: float) -> void:
	_voice_cd = maxf(_voice_cd - delta, 0.0)
	AudioServer.set_bus_volume_db(_sfx_bus, sfx_volume_db)
	AudioServer.set_bus_volume_db(_voice_bus, voice_volume_db)


## Play one sound of `event` at world position `at`. Returns true if
## something actually played (the voice rationing uses it).
func play(event: StringName, at: Vector2, force: bool = false) -> bool:
	if not enabled:
		return false
	var list: Array = _streams.get(event, [])
	if list.is_empty():
		return false
	var is_voice: bool = VOICE_EVENTS.has(event)
	if is_voice:
		if _voice_cd > 0.0 and not force:
			return false
		_voice_cd = VOICE_GAP
	else:
		var now: float = Time.get_ticks_msec() / 1000.0
		if now - float(_last_play.get(event, -100.0)) < float(EVENT_GAP.get(event, DEFAULT_GAP)):
			return false
		if _count_playing(event) >= MAX_SAME:
			return false
		_last_play[event] = now

	var p: AudioStreamPlayer2D
	if is_voice:
		p = _voice[_next_voice]
		_next_voice = (_next_voice + 1) % _voice.size()
	else:
		p = _sfx[_next_sfx]
		_next_sfx = (_next_sfx + 1) % _sfx.size()
	var spread: float = VOICE_PITCH if is_voice else sfx_pitch
	var jitter_db: float = VOICE_VOLUME_JITTER_DB if is_voice else sfx_volume_jitter_db
	p.stream = list[randi() % list.size()]
	p.pitch_scale = randf_range(1.0 - spread, 1.0 + spread)
	# Per-play volume offset on the player itself; the bus slider stays on top.
	p.volume_db = randf_range(-jitter_db, jitter_db)
	p.global_position = at
	p.set_meta(&"event", event)
	p.play()
	return true


## A random sound of `event`, for callers that drive their own player (the
## cauldron's whistle loops and bends pitch). null if the folder is empty.
func pick(event: StringName) -> AudioStream:
	var list: Array = _streams.get(event, [])
	return null if list.is_empty() else list[randi() % list.size()]


## True if `event` has any sound files - lets callers skip work for events
## that would be silent anyway.
func has(event: StringName) -> bool:
	return not (_streams.get(event, []) as Array).is_empty()


func _count_playing(event: StringName) -> int:
	var n: int = 0
	for p in _sfx:
		if p.playing and p.get_meta(&"event", &"") == event:
			n += 1
	return n


func _make_bus(bus_name: StringName) -> int:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, &"Master")
	return idx


func _make_player(bus: StringName) -> AudioStreamPlayer2D:
	var p := AudioStreamPlayer2D.new()
	p.bus = bus
	# Heard across a screen and a half, fading with distance from the camera,
	# so an enemy shooting from off screen is heard but quieter.
	p.max_distance = 2000.0
	p.attenuation = 1.0
	add_child(p)
	return p


## Read every event folder once. ResourceLoader.list_directory lists the
## imported resources, so it works in an exported APK too, where the raw
## .wav files are not shipped.
func _load_all() -> void:
	for folder in ResourceLoader.list_directory(ROOT):
		if not folder.ends_with("/"):
			continue
		var event := StringName(folder.trim_suffix("/"))
		var list: Array = []
		for f in ResourceLoader.list_directory(ROOT + folder):
			var ext: String = f.get_extension().to_lower()
			if ext in ["wav", "ogg", "mp3"]:
				var s: AudioStream = load(ROOT + folder + f)
				if s != null:
					list.append(s)
		_streams[event] = list
