extends BaseScreen
const GOAL := preload("res://scenes/ui/goal.tscn")
var session := GameSession.new()
var modal_mode: String = "intro"
var goals: Dictionary = {}
var continued: bool = false
func _ready() -> void:
	%TopBar.title = "Level %d" % Progress.selected_level
	%TopBar.get_node("Title").text = %TopBar.title
	%TopBar.back_pressed.connect(pause_game)
	%TopBar.wallet_pressed.connect(func(): notify("Visit Pip's shop from the main menu between levels."))
	%Board.move_used.connect(func(): session.moves -= 1; update_hud())
	%Board.cleared.connect(on_clear)
	%Board.settled.connect(on_settled)
	%Board.message.connect(notify)
	%Board.tool_target.connect(use_targeted)
	%Hammer.pressed.connect(select_booster.bind("hammer"))
	%Shuffle.pressed.connect(select_booster.bind("shuffle"))
	%Nova.pressed.connect(select_booster.bind("nova"))
	%Modal.primary_pressed.connect(modal_primary)
	%Modal.secondary_pressed.connect(modal_secondary)
	Progress.changed.connect(update_boosters)
	start_level()
func start_level() -> void:
	%TopBar.get_node("Title").text = "Level %d" % Progress.selected_level
	session.setup(Campaign.level(Progress.selected_level))
	var attempt := int(Progress.attempts.get(str(session.level.number), 0))
	Progress.attempts[str(session.level.number)] = attempt + 1
	%Board.setup(session.level, attempt); continued = false
	for child in %Goals.get_children(): %Goals.remove_child(child); child.queue_free()
	goals.clear()
	for key in session.level.goals():
		var goal := GOAL.instantiate(); %Goals.add_child(goal); goal.custom_minimum_size = Vector2(108,89)
		var art: String = {"score":"star", "ice":"ice", "stone":"stone", "collect":"gem_%d" % maxi(0, session.level.collect_color)}[key]
		goal.get_node("Art").texture = load("res://assets/art/"+art+".svg")
		goals[key] = goal
	%Combo.text = session.level.title
	update_hud(); update_boosters()
	modal_mode = "intro"
	%Modal.display("Level %d" % session.level.number, "%s • %s\n\n%s\n\n%d moves. Complete every goal!" % [Campaign.WORLDS[session.level.world], session.level.difficulty, session.level.tip, session.moves], "Let’s play!", "Back to map", "gem_1")
func update_hud() -> void:
	%Moves.text = str(session.moves); %Score.text = "SCORE  %s" % session.score
	%ScoreBar.max_value = maxi(2400, session.level.score_goal) * 2
	%ScoreBar.value = session.score
	for key in goals:
		var target: int = session.level.goals()[key]
		var value: int = mini(session.values()[key], target)
		goals[key].get_node("Count").text = "%d / %d" % [value, target]
		if value == target: goals[key].get_node("Count").modulate = Color("22867e")
func update_boosters() -> void:
	%Hammer.text = str(Progress.boosters.hammer); %Shuffle.text = str(Progress.boosters.shuffle); %Nova.text = str(Progress.boosters.nova)
func on_clear(result: Dictionary, chain: int) -> void:
	session.apply_clear(result, chain); update_hud()
	if chain >= 2: %Combo.text = ["", "", "Brilliant!", "Gemtastic!", "Absolutely dazzling!"][mini(chain,4)] + "  ×%d" % chain
	else: %Combo.text = "+%d  •  A little sparkle!" % result.score
func on_settled() -> void:
	if session.finished: return
	if session.won():
		session.finished = true; %Board.set_active(false)
		var stars := session.rating()
		var reward := Progress.complete(session.level.number, stars, session.score)
		modal_mode = "won"; Audio.play("win")
		%Modal.display("Island complete!" if session.level.number % 20 == 0 else "You're gemtastic!", "%d / 3 stars earned\n\nScore: %d  •  %d moves to spare\n+%d coins\n\n%s" % [stars, session.score, session.moves, reward, "All 200 levels complete. A brilliant adventure!" if session.level.number == 200 else "Pip can't wait for your next adventure."], "Back to adventure" if session.level.number == 200 else "Next level", "Back to map")
	elif session.moves <= 0:
		%Board.set_active(false); modal_mode = "lost"; Audio.play("bad")
		%Modal.display("So close!", "Every great gem hunter tries again.\n\nYour score: %d\n\n%s" % [session.score, "Add 5 moves for 100 coins, or retry for free." if not continued else "Take a fresh start. Retries are always free."], "+5 moves • 100 coins" if not continued else "Try again", "Retry for free" if not continued else "Back to map", "gem_0")
func pause_game() -> void:
	if %Modal.visible or %Board.state != %Board.State.IDLE: return
	%Board.set_active(false); modal_mode = "paused"
	%Modal.display("Take a little breather", "Your gems will be right here.\n\nComplete every goal before you run out of moves.\n\nLeaving returns you to the map; this attempt restarts.", "Keep playing", "Back to map", "gem_2")
func modal_primary() -> void:
	match modal_mode:
		"intro", "paused": %Modal.hide(); %Board.set_active(true)
		"won":
			if session.level.number == 200: go("map")
			else: Progress.selected_level = session.level.number + 1; start_level()
		"lost":
			if continued: start_level()
			elif Progress.spend(100):
				continued = true; session.moves += 5; %Modal.hide(); %Board.set_active(true); update_hud()
			else: notify("You need 100 coins. Tap Retry for free for a fresh board.")
func modal_secondary() -> void:
	if modal_mode == "lost" and not continued: start_level()
	else: go("map")
func select_booster(kind: String) -> void:
	if %Modal.visible or %Board.state != %Board.State.IDLE: return
	if Progress.boosters[kind] <= 0: notify("Your bag is empty. Find more in Pip's shop."); return
	if kind == "shuffle":
		if Progress.use_booster(kind): %Board.use_tool(kind); %Combo.text = "Fresh gems. Fresh possibilities!"
	else:
		%Board.arm(kind)
		%Combo.text = ("Tap a gem or stone. Tap hammer again to cancel." if kind == "hammer" else "Tap a gem color to clear it. Tap nova to cancel.") if %Board.armed_tool != "" else "Match a little magic!"
func use_targeted(kind: String, index: int) -> void:
	if not %Board.model.playable(index) and not (kind == "hammer" and %Board.model.stones[index] > 0): return
	if Progress.use_booster(kind): %Board.use_tool(kind, index)
