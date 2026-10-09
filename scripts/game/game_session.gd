class_name GameSession
extends RefCounted
var level: LevelData
var moves: int = 0
var score: int = 0
var collected: int = 0
var melted: int = 0
var broken: int = 0
var finished: bool = false
func setup(data: LevelData) -> void:
	level = data; moves = data.moves; score = 0; collected = 0; melted = 0; broken = 0; finished = false
func apply_clear(result: Dictionary, chain: int) -> void:
	score += result.score * mini(chain, 4)
	melted += result.ice; broken += result.stone
	if level.collect_color >= 0: collected += result.tally[level.collect_color]
func values() -> Dictionary:
	return {"score": score, "collect": collected, "ice": melted, "stone": broken}
func won() -> bool:
	var current := values()
	for key in level.goals():
		if current[key] < level.goals()[key]: return false
	return true
func rating() -> int:
	var target := maxi(2400, level.score_goal)
	return 3 if score >= target * 2 or moves >= level.moves * 0.35 else (2 if score >= target * 1.3 or moves >= level.moves * 0.15 else 1)
