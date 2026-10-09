extends Control
signal move_used
signal cleared(result: Dictionary, chain: int)
signal settled
signal message(text: String)
signal tool_target(kind: String, index: int)
enum State { LOCKED, IDLE, SWAPPING, RESOLVING }
const GEM := preload("res://scenes/game/gem.tscn")
const STONE := preload("res://assets/art/stone.svg")
const CELL := 78.0
var model := BoardModel.new()
var tiles: Array[Control] = []
var state: State = State.LOCKED
var selected: int = -1
var press_index: int = -1
var press_position := Vector2.ZERO
var armed_tool: String = ""
var hinted: Array = []
@onready var effects: Control = $Sparkles
func _ready() -> void:
	for i in range(64):
		var tile := GEM.instantiate(); %Gems.add_child(tile); tiles.append(tile)
		tile.position = cell_position(i); tile.size = Vector2(72,72); tile.pivot_offset = Vector2(36,36)
	%HintTimer.timeout.connect(show_hint)
func setup(level: LevelData, attempt: int) -> void:
	model.setup(level, attempt); state = State.LOCKED; refresh()
func cell_position(i: int) -> Vector2:
	return Vector2(i % 8, i / 8) * CELL + Vector2(3, 3)
func refresh() -> void:
	for i in range(64):
		tiles[i].configure(model.colors[i], model.specials[i], model.ice[i] > 0)
		tiles[i].position = cell_position(i); tiles[i].scale = Vector2.ONE
		tiles[i].selected = i == selected or i in hinted; tiles[i].queue_redraw()
	queue_redraw()
func _draw() -> void:
	if model.colors.is_empty(): return
	for i in range(64):
		if i in model.holes: continue
		var box := StyleBoxFlat.new(); box.set_corner_radius_all(10)
		box.bg_color = Color("315e82") if (i + i / 8) % 2 == 0 else Color("396a8d")
		draw_style_box(box, Rect2(cell_position(i)-Vector2(1,1),Vector2(74,74)))
		if model.stones[i] > 0: draw_texture_rect(STONE, Rect2(cell_position(i), Vector2(72,72)), false)
func set_active(active: bool) -> void:
	state = State.IDLE if active else State.LOCKED
	if active: %HintTimer.start()
	else: %HintTimer.stop()
func at_point(point: Vector2) -> int:
	if point.x < 0 or point.y < 0 or point.x >= 624 or point.y >= 624: return -1
	return int(point.y / CELL) * 8 + int(point.x / CELL)
func _gui_input(event: InputEvent) -> void:
	if state != State.IDLE: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if event.pressed:
			press_index = at_point(event.position); press_position = event.position
		else:
			if press_index < 0: return
			var released := at_point(event.position)
			if armed_tool.is_empty() and released >= 0 and released != press_index and event.position.distance_to(press_position) >= 18:
				var delta: Vector2 = event.position - press_position
				var neighbor := press_index + (signi(int(delta.x)) if absf(delta.x) > absf(delta.y) else signi(int(delta.y)) * 8)
				attempt_swap(press_index, neighbor)
			else: tap(press_index)
			press_index = -1
func tap(index: int) -> void:
	if state != State.IDLE or index < 0: return
	hinted.clear(); %HintTimer.start()
	if not armed_tool.is_empty(): tool_target.emit(armed_tool, index); return
	if not model.playable(index): return
	if selected >= 0 and index in model.neighbors(selected): attempt_swap(selected, index)
	else:
		selected = -1 if selected == index else index
		Audio.play("tap"); refresh()
func attempt_swap(a: int, b: int) -> void:
	if state != State.IDLE or not model.playable(a) or not model.playable(b) or b not in model.neighbors(a): return
	state = State.SWAPPING; selected = -1; hinted.clear(); %HintTimer.stop()
	for tile in tiles: tile.selected = false; tile.queue_redraw()
	await animate_swap(a, b)
	var result := model.begin_swap(a, b)
	if not result.valid:
		Audio.play("bad"); await animate_swap(a, b, true); refresh(); set_active(true); return
	move_used.emit(); Audio.haptic(); refresh()
	await resolve_chain(result.groups, result.force)
func animate_swap(a: int, b: int, reverse: bool = false) -> void:
	var tween := create_tween().set_parallel(true)
	var duration := 0.05 if Progress.settings.reduced_motion else 0.16
	tween.tween_property(tiles[a], "position", cell_position(a if reverse else b), duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(tiles[b], "position", cell_position(b if reverse else a), duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
func resolve_chain(groups: Array, force: Array = []) -> void:
	state = State.RESOLVING
	var chain := 1
	while not groups.is_empty() or not force.is_empty():
		var result := model.resolve(groups, force)
		cleared.emit(result, chain)
		Audio.play("match", minf(1.0 + (chain - 1) * 0.12, 1.8))
		var tween := create_tween().set_parallel(true)
		for i in result.cells:
			effects.burst(cell_position(i)+Vector2(36,36), Color("ffec96") if chain > 1 else Color("a5f9ff"))
			tween.tween_property(tiles[i], "scale", Vector2(0.1,0.1), 0.07 if Progress.settings.reduced_motion else 0.17)
		if result.cells.is_empty(): tween.tween_interval(0.01)
		await tween.finished
		var drops := model.collapse(); refresh()
		var falling := create_tween().set_parallel(true)
		for drop in drops:
			var tile: Control = tiles[drop[1]]
			tile.position = cell_position(drop[0]) if drop[0] >= 0 else cell_position(drop[1]) - Vector2(0, CELL * 1.4)
			falling.tween_property(tile, "position", cell_position(drop[1]), 0.06 if Progress.settings.reduced_motion else 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if drops.is_empty(): falling.tween_interval(0.01)
		await falling.finished
		groups = MatchFinder.groups(model.colors); force = []; chain += 1
		if chain > 40: model.shuffle(); refresh(); break
	if model.legal_moves().is_empty():
		model.shuffle(); refresh(); message.emit("A fresh sparkle! No moves were available.")
	set_active(true); settled.emit()
func arm(kind: String) -> void:
	if state != State.IDLE: return
	armed_tool = "" if armed_tool == kind else kind
	selected = -1; hinted.clear(); refresh()
func use_tool(kind: String, index: int = -1) -> void:
	if state != State.IDLE: return
	armed_tool = ""; selected = -1; hinted.clear()
	if kind == "shuffle":
		model.shuffle(); refresh(); Audio.play("match"); settled.emit(); %HintTimer.start(); return
	if index < 0: return
	if kind == "hammer" and model.stones[index] > 0:
		model.stones[index] = 0
		cleared.emit({"score":60,"ice":0,"stone":1,"tally":[0,0,0,0,0,0]}, 1)
		model.collapse(); refresh(); await resolve_chain(MatchFinder.groups(model.colors)); return
	var force: Array[int] = [index]
	if kind == "nova":
		force.clear()
		for i in range(64):
			if model.playable(i) and model.colors[i] == model.colors[index]: force.append(i)
	await resolve_chain([], force)
func show_hint() -> void:
	if state != State.IDLE or not armed_tool.is_empty(): return
	var moves := model.legal_moves()
	if not moves.is_empty(): hinted = moves[0]; refresh()
