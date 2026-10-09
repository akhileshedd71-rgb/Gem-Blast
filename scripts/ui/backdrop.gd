@tool
extends Control
var time: float = 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	if not Engine.is_editor_hint(): Progress.changed.connect(queue_redraw)
func _draw() -> void:
	var top := Color("def7f5")
	var bottom := Color("a7dce5")
	if not Engine.is_editor_hint():
		if Progress.skin == "Rose Quartz": top = Color("fde9f4"); bottom = Color("ddbbe9")
		if Progress.skin == "Starlight": top = Color("dce4fd"); bottom = Color("b3b6e7")
	for y in range(0, int(size.y), 8):
		draw_rect(Rect2(0, y, size.x, 8), top.lerp(bottom, float(y) / maxf(size.y, 1)))
	for i in range(12):
		var p := Vector2(fmod(i * 173.0 + 45, maxf(size.x, 1)), fmod(i * 237.0 + 38, maxf(size.y, 1)))
		draw_circle(p, 26 + (i % 4) * 22, Color(1, 1, 1, 0.12))
	for side in [-1, 1]:
		var cx: float = 25.0 if side < 0 else size.x - 20
		var cy := size.y * 0.84
		var points := PackedVector2Array([Vector2(cx-58, cy+160), Vector2(cx-72, cy+14), Vector2(cx-30, cy-70), Vector2(cx+14, cy-13), Vector2(cx+28,cy+160)])
		draw_colored_polygon(points, Color(0.53, 0.55, 0.86, 0.24))
		draw_line(Vector2(cx-30,cy-70),Vector2(cx-9,cy+150),Color(1,1,1,0.3),3)
	for i in range(17):
		var p := Vector2(fmod(i * 127.0 + 11, maxf(size.x, 1)), fmod(i * 311.0 + 45, maxf(size.y, 1)))
		draw_line(p-Vector2(5,0),p+Vector2(5,0),Color(1,1,1,0.65),2)
		draw_line(p-Vector2(0,5),p+Vector2(0,5),Color(1,1,1,0.65),2)
