extends Control
const TEXTURES := [preload("res://assets/art/gem_0.svg"), preload("res://assets/art/gem_1.svg"), preload("res://assets/art/gem_2.svg"), preload("res://assets/art/gem_3.svg"), preload("res://assets/art/gem_4.svg"), preload("res://assets/art/gem_5.svg")]
var special: int = 0
var selected: bool = false
var frozen: bool = false
func configure(color_index: int, type: int, icy: bool) -> void:
	visible = color_index >= 0
	if visible: %Art.texture = TEXTURES[color_index]
	special = type; frozen = icy
	queue_redraw()
func _draw() -> void:
	if frozen:
		draw_style_box(ice_style(), Rect2(1, 1, 70, 70))
		draw_line(Vector2(6, 18), Vector2(25, 4), Color(1, 1, 1, 0.75), 3)
	if special == BoardModel.Special.ROW:
		for y in [29, 37, 45]: draw_line(Vector2(12, y), Vector2(60, y), Color(1, 1, 1, 0.95), 4, true)
	elif special == BoardModel.Special.COLUMN:
		for x in [29, 37, 45]: draw_line(Vector2(x, 12), Vector2(x, 60), Color(1, 1, 1, 0.95), 4, true)
	elif special == BoardModel.Special.BOMB:
		draw_circle(Vector2(36, 37), 18, Color("ffec8c"))
		draw_circle(Vector2(36, 37), 11, Color("fc79bf"))
		draw_arc(Vector2(36, 37), 25, 0, TAU, 36, Color.WHITE, 3, true)
	elif special == BoardModel.Special.PRISM:
		for i in range(6): draw_arc(Vector2(36, 36), 27, i * TAU / 6, (i+1) * TAU / 6, 12, Color.from_hsv(float(i)/6, 0.65, 1), 7, true)
		draw_circle(Vector2(36,36), 12, Color.WHITE)
	if selected:
		draw_arc(Vector2(36,36), 35, 0, TAU, 48, Color("fff29b"), 4, true)
func ice_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.93, 1, 0.23)
	style.border_color = Color(0.82, 1, 1, 0.8)
	style.set_border_width_all(2); style.set_corner_radius_all(12)
	return style
