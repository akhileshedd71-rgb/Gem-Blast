class_name MatchFinder
extends RefCounted
## Pure, side-effect-free run detection. Intersecting runs form one group.
static func groups(colors: Array[int], width: int = 8) -> Array:
	var runs: Array = []
	for vertical in [false, true]:
		for line in range(width):
			var current: Array[int] = []
			var last: int = -99
			for step in range(width + 1):
				var idx: int = line * width + step if not vertical else step * width + line
				var color: int = colors[idx] if step < width else -99
				if color != last or color < 0:
					if current.size() >= 3: runs.append({"cells": current.duplicate(), "vertical": vertical, "longest": current.size(), "cross": false})
					current.clear()
				if color >= 0: current.append(idx)
				last = color
	var merged := true
	while merged:
		merged = false
		for a in range(runs.size()):
			if merged: break
			for b in range(a + 1, runs.size()):
				var overlap := false
				for idx in runs[a].cells:
					if idx in runs[b].cells: overlap = true; break
				if overlap:
					for idx in runs[b].cells:
						if idx not in runs[a].cells: runs[a].cells.append(idx)
					runs[a].cross = true
					runs[a].longest = maxi(runs[a].longest, runs[b].longest)
					runs.remove_at(b)
					merged = true
					break
	return runs
