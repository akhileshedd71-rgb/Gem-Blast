extends Control
var points: Array[Vector2] = []
func _draw() -> void:
	if points.size() < 2: return
	for i in range(points.size() - 1):
		draw_line(points[i] + Vector2(0, 7), points[i+1] + Vector2(0, 7), Color("79bcca"), 20, true)
		draw_line(points[i], points[i+1], Color("ffefb1"), 17, true)
		draw_dashed_line(points[i], points[i+1], Color("e4b875"), 3, 9, true)
