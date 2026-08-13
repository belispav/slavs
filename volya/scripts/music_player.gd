extends Node

## VOLYA - background music.
##
## Prototype stage: one track (Suno-generated MP3, dropped in from
## ref/audio/Protomusic.mp3) played on loop. Godot imports .mp3 natively and
## AudioStreamMP3 has its own loop property, so no conversion is needed just
## to hear music in the prototype - see CLAUDE.md for the plan to convert to
## OGG Vorbis once real WAV masters exist (Suno licence requires a
## subscription for WAV export, deferred until then).
##
## Swapping in separate level/boss tracks later is a matter of adding more
## entries here and picking one in play_track() - nothing else in the game
## needs to change.

const TRACK_PROTOTYPE: String = "res://audio/music/protomusic.mp3"

var enabled: bool = true

var _player: AudioStreamPlayer


func _ready() -> void:
	# So music keeps playing (or stays correctly stopped) through the debug
	# panel's PAUZA switch, same reasoning as the panel itself.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player = AudioStreamPlayer.new()
	_player.name = "MusicStream"
	add_child(_player)

	play_track(TRACK_PROTOTYPE)


## Loads and plays a track by resource path, looping it. Safe to call again
## later to switch tracks (e.g. level vs boss music, once those exist).
func play_track(path: String) -> void:
	var stream: AudioStream = load(path)
	if stream == null:
		push_warning("Music: nepodarilo sa nacitat %s" % path)
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	_player.stream = stream
	if enabled:
		_player.play()


func set_enabled(on: bool) -> void:
	enabled = on
	if _player == null:
		return
	if on:
		if _player.stream != null and not _player.playing:
			_player.play()
	else:
		_player.stop()
