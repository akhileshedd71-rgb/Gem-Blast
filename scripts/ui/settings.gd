extends BaseScreen
func _ready() -> void:
	connect_top()
	for pair in [[%Music, "music"], [%Sound, "sound"], [%Haptics, "haptics"], [%Motion, "reduced_motion"]]:
		pair[0].pressed.connect(toggle.bind(pair[1]))
	refresh()
func toggle(key: String) -> void:
	Progress.settings[key] = not Progress.settings[key]; Progress.save(); Audio.play("tap"); refresh()
func refresh() -> void:
	for pair in [[%Music, "music"], [%Sound, "sound"], [%Haptics, "haptics"], [%Motion, "reduced_motion"]]:
		pair[0].text = "On" if Progress.settings[pair[1]] else "Off"
