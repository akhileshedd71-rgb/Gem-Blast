extends Node
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var next_voice: int = 0
const SOUNDS := {"tap": "res://assets/audio/tap.wav", "match": "res://assets/audio/match.wav", "win": "res://assets/audio/win.wav", "bad": "res://assets/audio/bad.wav"}
func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.stream = load("res://assets/audio/isles.wav")
	music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.stream.loop_end = music.stream.data.size() / 2
	music.volume_db = -21
	add_child(music)
	for i in range(6):
		var player := AudioStreamPlayer.new(); add_child(player); voices.append(player)
	Progress.changed.connect(apply_settings)
	apply_settings()
func apply_settings() -> void:
	if Progress.settings.music and DisplayServer.get_name() != "headless":
		if not music.playing: music.play()
	else: music.stop()
func play(kind: String, pitch: float = 1.0) -> void:
	if not Progress.settings.sound or not SOUNDS.has(kind) or DisplayServer.get_name() == "headless": return
	var voice := voices[next_voice]; next_voice = (next_voice + 1) % voices.size()
	voice.stream = load(SOUNDS[kind]); voice.pitch_scale = pitch; voice.volume_db = -12; voice.play()
func haptic() -> void:
	if Progress.settings.haptics and OS.has_feature("mobile"): Input.vibrate_handheld(24)

func _exit_tree() -> void:
	if is_instance_valid(music): music.stop(); music.stream = null
	for voice in voices:
		if is_instance_valid(voice): voice.stop()
