extends BaseScreen
const NODE_SCENE := preload("res://scenes/ui/level_node.tscn")
var world: int = 0
func _ready() -> void:
	connect_top()
	world = (Progress.selected_level - 1) / 20
	%Previous.pressed.connect(change_world.bind(-1))
	%Next.pressed.connect(change_world.bind(1))
	%Continue.pressed.connect(func(): Progress.selected_level = Progress.unlocked; go("game"))
	build()
func change_world(direction: int) -> void:
	world = clampi(world + direction, 0, 9); Audio.play("tap"); build()
func build() -> void:
	for child in %Trail.get_children(): %Trail.remove_child(child); child.queue_free()
	%Trail.points.clear()
	%Chapter.text = "CHAPTER %02d / 10" % (world + 1)
	%World.text = Campaign.WORLDS[world]
	%Previous.disabled = world == 0; %Next.disabled = world == 9
	var total := 0
	for index in range(20):
		var n := world * 20 + index + 1
		var row := index / 4
		var col := index % 4 if row % 2 == 0 else 3 - index % 4
		var pos := Vector2(52 + col * 145, 590 - row * 133 + sin(col * 1.6) * 16)
		%Trail.points.append(pos + Vector2(40, 37))
		var item := NODE_SCENE.instantiate()
		%Trail.add_child(item); item.position = pos; item.size = Vector2(80, 100)
		var button := item.get_node("Button") as Button
		button.text = str(n)
		var locked := n > Progress.unlocked
		button.disabled = locked
		if locked: button.icon = preload("res://assets/art/lock.svg"); button.expand_icon = true; button.add_theme_constant_override("icon_max_width", 22)
		if n == Progress.unlocked: button.theme_type_variation = "Button"; button.scale = Vector2(1.12, 1.12)
		var rating := int(Progress.stars.get(str(n), 0)); total += rating
		for s in range(3): item.get_node("Star" + str(s)).modulate = Color.WHITE if s < rating else Color(0.48, 0.58, 0.68, 0.55)
		button.pressed.connect(func(): Progress.selected_level = n; go("game"))
	%WorldProgress.text = "%d / 60 stars" % total
	%Trail.queue_redraw()
