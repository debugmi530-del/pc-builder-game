extends Node

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var music_volume: float = 0.8
var sfx_volume: float = 1.0

func _ready() -> void:
	add_child(music_player)
	add_child(sfx_player)
	music_player.bus = "Music"
	sfx_player.bus = "SFX"
	_apply_volumes()

func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = linear_to_db(sfx_volume)
	player.play()
	player.finished.connect(player.queue_free)

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_apply_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	_apply_volumes()

func _apply_volumes() -> void:
	music_player.volume_db = linear_to_db(music_volume) if music_volume > 0 else -80.0
	sfx_player.volume_db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80.0
