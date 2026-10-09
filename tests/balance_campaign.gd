extends SceneTree
func _init() -> void: call_deferred("run")
func run() -> void:
	var wins: Array[int]=[]; wins.resize(10); wins.fill(0)
	var failures: Array[int]=[]
	var rows: Array=[]
	for n in range(1,201):
		var level:=Campaign.level(n); var b:=BoardModel.new(); b.setup(level)
		var session:=GameSession.new(); session.setup(level)
		while session.moves>0 and not session.won():
			var moves:=b.legal_moves()
			if moves.is_empty(): b.shuffle(); moves=b.legal_moves()
			var saved_c:=b.colors.duplicate();var saved_s:=b.specials.duplicate();var saved_i:=b.ice.duplicate();var saved_b:=b.stones.duplicate();var saved_r:=b.rng.state
			var best: Array=moves[0]; var best_value:float=-1
			for move in moves:
				var candidate:=b.begin_swap(move[0],move[1]); var clear:=b.resolve(candidate.groups,candidate.force)
				var value:float=clear.score*.1+clear.created.size()*80
				if session.melted<level.ice_cells.size():value+=clear.ice*250
				if session.broken<level.stone_cells.size():value+=clear.stone*250
				if session.collected<level.collect_goal:value+=clear.tally[level.collect_color]*100
				if value>best_value:best_value=value;best=move
				b.colors=saved_c.duplicate();b.specials=saved_s.duplicate();b.ice=saved_i.duplicate();b.stones=saved_b.duplicate();b.rng.state=saved_r
			var chosen:=b.begin_swap(best[0],best[1]);var groups:Array=chosen.groups;var forced:Array=chosen.force;var chain:=1
			while not groups.is_empty() or not forced.is_empty():
				var result:=b.resolve(groups,forced);session.apply_clear(result,chain);b.collapse();groups=MatchFinder.groups(b.colors);forced=[];chain+=1
				if chain>40:b.shuffle();break
			session.moves-=1
		if session.won():wins[level.world]+=1
		else:failures.append(n)
		rows.append({"level":n,"won":session.won(),"moves_left":session.moves,"score":session.score,"goals":level.goals(),"achieved":session.values()})
		if n%20==0:print("World %d: %d/20 greedy-bot wins" % [level.world+1,wins[level.world]])
	var file:=FileAccess.open("user://campaign-balance.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows,"  "));file.close()
	print("BALANCE: wins by world ",wins,"; unwon seed-0 levels ",failures)
	quit()
