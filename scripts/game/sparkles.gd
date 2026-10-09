extends Control
var particles: Array = []
func burst(point: Vector2, color: Color) -> void:
	if Progress.settings.reduced_motion: return
	for i in range(7):
		var angle := float(i) * TAU / 7
		particles.append({"p": point, "v": Vector2(cos(angle), sin(angle)) * randf_range(70, 180), "life": 0.5, "color": color})
func _process(delta: float) -> void:
	if particles.is_empty(): return
	for i in range(particles.size()-1, -1, -1):
		var p: Dictionary = particles[i]
		p.life -= delta; p.p += p.v * delta; p.v.y += delta * 260
		if p.life <= 0: particles.remove_at(i)
	queue_redraw()
func _draw() -> void:
	for p in particles:
		var c: Color = p.color; c.a = p.life * 2
		draw_circle(p.p, maxf(1, p.life * 9), c)
