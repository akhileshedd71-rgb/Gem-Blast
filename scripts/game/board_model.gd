class_name BoardModel
extends RefCounted
## Rules live independently of the animated scene, enabling deterministic tests.
enum Special { NONE, ROW, COLUMN, BOMB, PRISM }
const WIDTH := 8
const COUNT := 64
var colors: Array[int] = []
var specials: Array[int] = []
var ice: Array[int] = []
var stones: Array[int] = []
var holes: Array[int] = []
var rng := RandomNumberGenerator.new()
var palette: int = 5
var last_swap: Array[int] = []

func setup(level: LevelData, attempt: int = 0) -> void:
	rng.seed = level.seed_value + attempt * 7919
	palette = level.colors
	colors.assign(range(COUNT)); specials.resize(COUNT); specials.fill(0)
	ice.resize(COUNT); ice.fill(0); stones.resize(COUNT); stones.fill(0)
	holes.assign(level.void_cells)
	for i in level.ice_cells: ice[i] = 1
	for i in level.stone_cells: stones[i] = 1
	shuffle()

func playable(i: int) -> bool:
	return i >= 0 and i < COUNT and i not in holes and stones[i] == 0

func neighbors(i: int) -> Array[int]:
	var result: Array[int] = []
	for j in [i - 8, i + 8, i - 1, i + 1]:
		if j >= 0 and j < COUNT and absi(i % 8 - j % 8) + absi(i / 8 - j / 8) == 1: result.append(j)
	return result

func shuffle() -> void:
	# Regenerate a stable, playable board; objectives and blockers are preserved.
	for attempt in range(100):
		for i in range(COUNT):
			specials[i] = 0
			if not playable(i): colors[i] = -1; continue
			var choices: Array[int] = []
			for c in range(palette):
				if i % 8 >= 2 and colors[i - 1] == c and colors[i - 2] == c: continue
				if i >= 16 and colors[i - 8] == c and colors[i - 16] == c: continue
				choices.append(c)
			colors[i] = choices[rng.randi_range(0, choices.size() - 1)]
		if not legal_moves().is_empty(): return
	push_error("Board could not be shuffled into a playable state")

func swap_cells(a: int, b: int) -> void:
	var c := colors[a]; colors[a] = colors[b]; colors[b] = c
	var s := specials[a]; specials[a] = specials[b]; specials[b] = s

func legal_moves() -> Array:
	var moves: Array = []
	for a in range(COUNT):
		if not playable(a): continue
		for b in [a + 1, a + 8]:
			if b not in neighbors(a) or not playable(b): continue
			if specials[a] == Special.PRISM or specials[b] == Special.PRISM or (specials[a] > 0 and specials[b] > 0):
				moves.append([a, b]); continue
			swap_cells(a, b)
			if not MatchFinder.groups(colors).is_empty(): moves.append([a, b])
			swap_cells(a, b)
	return moves

func begin_swap(a: int, b: int) -> Dictionary:
	if not playable(a) or not playable(b) or b not in neighbors(a): return {"valid": false}
	last_swap = [b, a]
	swap_cells(a, b)
	var force: Array[int] = []
	if specials[a] == Special.PRISM or specials[b] == Special.PRISM:
		var prism: int = a if specials[a] == Special.PRISM else b
		var other: int = b if prism == a else a
		for i in range(COUNT):
			if playable(i) and (specials[other] == Special.PRISM or colors[i] == colors[other]):
				force.append(i)
				if specials[other] > 0 and specials[other] != Special.PRISM: specials[i] = specials[other]
		force.append(prism)
	elif specials[a] > 0 and specials[b] > 0:
		force.assign([a, b])
		if specials[a] == Special.BOMB or specials[b] == Special.BOMB:
			for i in range(COUNT):
				if playable(i) and (absi(i % 8 - b % 8) <= 2 and absi(i / 8 - b / 8) <= 2): force.append(i)
		else:
			specials[a] = Special.ROW; specials[b] = Special.COLUMN
	var groups := MatchFinder.groups(colors)
	if force.is_empty() and groups.is_empty():
		swap_cells(a, b)
		return {"valid": false}
	return {"valid": true, "groups": groups, "force": force}

func resolve(groups: Array, forced: Array = []) -> Dictionary:
	var clear: Array[int] = []
	var created: Dictionary = {}
	var created_colors: Dictionary = {}
	for g in groups:
		for i in g.cells:
			if i not in clear: clear.append(i)
		if g.cells.size() >= 4:
			var anchor: int = g.cells[g.cells.size() / 2]
			for i in last_swap:
				if i in g.cells: anchor = i; break
			created_colors[anchor] = colors[anchor]
			created[anchor] = Special.PRISM if g.longest >= 5 else (Special.BOMB if g.cross else (Special.COLUMN if g.vertical else Special.ROW))
	for i in forced:
		if playable(i) and i not in clear: clear.append(i)
	var cursor := 0
	while cursor < clear.size():
		var i := clear[cursor]; cursor += 1
		var targets: Array[int] = []
		match specials[i]:
			Special.ROW:
				for x in range(8): targets.append((i / 8) * 8 + x)
			Special.COLUMN:
				for y in range(8): targets.append(y * 8 + i % 8)
			Special.BOMB:
				for j in range(COUNT):
					if absi(j % 8 - i % 8) <= 1 and absi(j / 8 - i / 8) <= 1: targets.append(j)
			Special.PRISM:
				for j in range(COUNT):
					if colors[j] == colors[i]: targets.append(j)
		for j in targets:
			if playable(j) and j not in clear: clear.append(j)
	var tally: Array[int] = [0, 0, 0, 0, 0, 0]
	var ice_count := 0
	var stone_hits: Array[int] = []
	for i in clear:
		if colors[i] >= 0: tally[colors[i]] += 1
		if ice[i] > 0: ice[i] = 0; ice_count += 1
		for j in neighbors(i):
			if stones[j] > 0 and j not in stone_hits: stone_hits.append(j)
		colors[i] = -1; specials[i] = 0
	for j in stone_hits: stones[j] = 0
	for i in created:
		colors[i] = created_colors[i]
		specials[i] = created[i]
	last_swap.clear()
	return {"cells": clear, "created": created, "tally": tally, "ice": ice_count, "stone": stone_hits.size(), "stone_cells": stone_hits, "score": clear.size() * 60 + created.size() * 120}

func collapse() -> Array:
	var drops: Array = []
	for x in range(8):
		var bottom := 7
		while bottom >= 0:
			if not playable(bottom * 8 + x): bottom -= 1; continue
			var top := bottom
			while top > 0 and playable((top - 1) * 8 + x): top -= 1
			var write := bottom
			for y in range(bottom, top - 1, -1):
				var source := y * 8 + x
				if colors[source] < 0: continue
				var dest := write * 8 + x
				if dest != source:
					colors[dest] = colors[source]; specials[dest] = specials[source]
					colors[source] = -1; specials[source] = 0
					drops.append([source, dest])
				write -= 1
			for y in range(write, top - 1, -1):
				var idx := y * 8 + x
				colors[idx] = rng.randi_range(0, palette - 1); specials[idx] = 0
				drops.append([-1, idx])
			bottom = top - 1
	return drops
