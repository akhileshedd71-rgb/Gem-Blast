extends BaseScreen
func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(%Loading, "value", 100.0, 1.2)
	tween.tween_interval(0.25)
	tween.tween_callback(go.bind("home"))
