class_name LevelData
extends Resource
## Each campaign level is independently editable in the Inspector.
@export_range(1, 200) var number: int = 1
@export var title: String = "A sparkling start"
@export_range(0, 9) var world: int = 0
@export var difficulty: String = "Sweet"
@export var seed_value: int = 1001
@export_range(3, 6) var colors: int = 5
@export_range(10, 50) var moves: int = 28
@export var score_goal: int = 1800
@export var collect_color: int = -1
@export var collect_goal: int = 0
@export var ice_cells: PackedInt32Array = []
@export var stone_cells: PackedInt32Array = []
@export var void_cells: PackedInt32Array = []
@export var tip: String = "Swap neighboring gems to match three."

func goals() -> Dictionary:
	var result: Dictionary = {}
	if score_goal > 0: result["score"] = score_goal
	if collect_goal > 0: result["collect"] = collect_goal
	if not ice_cells.is_empty(): result["ice"] = ice_cells.size()
	if not stone_cells.is_empty(): result["stone"] = stone_cells.size()
	return result
