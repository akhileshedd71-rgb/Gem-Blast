extends SceneTree
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(message)
func _init() -> void:
	call_deferred("run")
func blank_board() -> BoardModel:
	var b := BoardModel.new(); b.setup(Campaign.level(1))
	b.colors.fill(-1); b.specials.fill(0); b.stones.fill(0); b.ice.fill(0)
	return b
func run() -> void:
	# Four, five and intersecting matches create the promised special types.
	for count in [3,4,5]:
		var b := blank_board()
		for i in range(count): b.colors[16+i] = 2
		var groups := MatchFinder.groups(b.colors)
		check(groups.size()==1, "one run of %d" % count)
		var result := b.resolve(groups)
		check(result.cells.size()==count, "clear exact run")
		check(result.created.size()==int(count>=4), "special creation threshold")
		if count==5: check(BoardModel.Special.PRISM in b.specials, "five makes prism")
	var cross := blank_board()
	for i in [19,26,27,28,35]: cross.colors[i] = 1
	var cross_groups := MatchFinder.groups(cross.colors)
	check(cross_groups.size()==1 and cross_groups[0].cross, "intersecting runs merge")
	cross.resolve(cross_groups)
	check(BoardModel.Special.BOMB in cross.specials, "T makes burst")
	# Ice and stones respond to clears, with unique blocker counts.
	var b := blank_board()
	for i in [24,25,26]: b.colors[i]=0; b.ice[i]=1
	b.stones[33]=1
	var result := b.resolve(MatchFinder.groups(b.colors))
	check(result.ice==3 and result.stone==1, "ice and adjacent stone collected once")
	# Stripe chaining and prism swaps.
	b.setup(Campaign.level(1)); b.specials[0]=BoardModel.Special.ROW; b.specials[5]=BoardModel.Special.COLUMN
	result=b.resolve([], [0])
	check(result.cells.size()>=15, "stripes chain across row and column")
	b.setup(Campaign.level(1)); b.specials[0]=BoardModel.Special.PRISM
	var color := b.colors[1]; var expected := b.colors.count(color)
	var swap := b.begin_swap(0,1)
	check(swap.valid, "prism swaps without a natural match")
	result=b.resolve(swap.groups, swap.force)
	check(result.cells.size()>=expected, "prism clears selected color")
	b.setup(Campaign.level(1)); b.specials[0]=BoardModel.Special.PRISM; b.specials[1]=BoardModel.Special.PRISM
	swap=b.begin_swap(0,1); result=b.resolve(swap.groups,swap.force)
	check(result.cells.size()==64, "double prism clears board")
	# Invalid swaps restore both arrays exactly and do not wrap rows.
	b.setup(Campaign.level(1)); var original:=b.colors.duplicate()
	check(not b.begin_swap(7,8).valid and original==b.colors, "row wrap forbidden")
	var invalid_found := false
	for a in range(64):
		for target in b.neighbors(a):
			var saved := b.colors.duplicate()
			var attempt := b.begin_swap(a,target)
			if not attempt.valid:
				check(saved==b.colors, "invalid move is reverted"); invalid_found=true; break
			b.swap_cells(a,target)
		if invalid_found: break
	# Validate every saved resource and many complete turns, including blockers.
	for n in range(1,201):
		var level := Campaign.level(n)
		check(level.number==n and level.world==(n-1)/20, "campaign numbering %d" % n)
		check(not level.goals().is_empty(), "goals exist %d" % n)
		b=BoardModel.new(); b.setup(level)
		check(MatchFinder.groups(b.colors).is_empty(), "stable start %d" % n)
		check(not b.legal_moves().is_empty(), "playable start %d" % n)
		for i in level.void_cells: check(i not in level.ice_cells and i not in level.stone_cells, "mask excludes goals")
		for turn in range(8):
			var available:=b.legal_moves()
			if available.is_empty(): b.shuffle(); available=b.legal_moves()
			swap=b.begin_swap(available[0][0],available[0][1])
			check(swap.valid,"legal move accepted")
			var groups: Array=swap.groups; var forced: Array=swap.force; var chain:=0
			while not groups.is_empty() or not forced.is_empty():
				b.resolve(groups,forced); b.collapse(); groups=MatchFinder.groups(b.colors); forced=[]; chain+=1
				if chain>50: check(false,"cascade terminates");break
			for i in range(64):
				check((b.colors[i]>=0)==b.playable(i), "gravity fills playable cells %d" % n)
	# Progress, currency and replay rewards are integration tested without touching player data.
	var progress := root.get_node("Progress")
	progress.persistence_enabled=false; progress.stars={}; progress.scores={}; progress.coins=350; progress.unlocked=1
	check(progress.complete(1,2,1500)==150,"first clear reward")
	check(progress.complete(1,2,1400)==0,"replay cannot farm currency")
	check(progress.complete(1,3,2000)==25,"better stars reward difference")
	check(progress.scores["1"]==2000 and progress.unlocked==2,"best score and unlock persist in state")
	check(not progress.spend(999999) and not progress.spend(-10),"cannot overspend or spend negative")
	progress.daily=""; check(progress.claim_daily() and not progress.claim_daily(),"daily once only")
	var session:=GameSession.new(); session.setup(Campaign.level(1))
	check(not session.won(),"win requires goals")
	session.score=session.level.score_goal; check(session.won(),"score objective wins")
	print("CORE TESTS: %d checks, %d failures; all 200 levels, 1600 turns." % [checks,failures])
	quit(1 if failures else 0)
