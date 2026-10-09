extends SceneTree
var checks: int=0
var failures: int=0
var app: Control
func check(value: bool, message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func _init() -> void: call_deferred("run")
func wait_board(board: Control) -> void:
	for i in range(500):
		await process_frame
		if board.state==board.State.IDLE or app.current.get_node("Modal").visible:return
	check(false,"animated board settled before timeout")
func run() -> void:
	var progress=root.get_node("Progress")
	progress.persistence_enabled=false;progress.settings.reduced_motion=true;progress.selected_level=1;progress.unlocked=1;progress.coins=350;progress.stars={};progress.scores={}
	app=load("res://scenes/main.tscn").instantiate();root.add_child(app)
	await create_timer(1.6).timeout
	check(app.page=="home","splash routes to home")
	app.current.get_node("Map").pressed.emit()
	check(app.page=="map" and app.current.get_node("Trail").get_child_count()==20,"map shows 20 level nodes")
	check(app.current.get_node("Trail").get_child(1).get_node("Button").disabled,"unearned levels locked")
	app.current.get_node("Next").pressed.emit()
	check(app.current.world==1,"next world browse")
	app.show_screen("shop")
	var prior:int=progress.coins;var quantity:int=progress.boosters.hammer
	app.current.get_node("Products").get_child(0).get_node("Buy").pressed.emit()
	check(progress.coins==prior-120 and progress.boosters.hammer==quantity+1,"shop spends earned coins and grants booster")
	prior=progress.coins;app.current.get_node("CoinSoon").pressed.emit()
	check(progress.coins==prior,"future coin packs never charge")
	app.show_screen("wardrobe");progress.coins=1000
	app.current.get_node("Styles").get_child(1).get_node("Buy").pressed.emit()
	check(progress.skin=="Rose Quartz" and progress.coins==650,"buy and equip cosmetic")
	app.current.choose("Rose Quartz",350);check(progress.coins==650,"owned cosmetic is free to equip")
	app.show_screen("settings")
	var sound:bool=progress.settings.sound;app.current.get_node("Sound").pressed.emit()
	check(progress.settings.sound!=sound,"sound toggle wired")
	progress.settings.sound=false
	app.show_screen("game")
	var game=app.current;var board=game.get_node("Board")
	check(game.get_node("Modal").visible and board.state==board.State.LOCKED,"level briefing blocks board")
	game.get_node("Modal/Primary").pressed.emit()
	check(not game.get_node("Modal").visible and board.state==board.State.IDLE,"play activates board")
	var moves:int=game.session.moves
	var pair=board.model.legal_moves()[0]
	board.tap(pair[0]);board.tap(pair[1]);await wait_board(board)
	check(game.session.moves==moves-1 and game.session.score>0,"tap pair consumes one move and scores")
	check(MatchFinder.groups(board.model.colors).is_empty(),"animated cascade ends stable")
	game.pause_game();check(game.modal_mode=="paused" and board.state==board.State.LOCKED,"pause freezes board")
	game.modal_primary()
	# Swipe via the same mouse events Godot's touchscreen emulation emits.
	pair=board.model.legal_moves()[0];moves=game.session.moves
	var down:=InputEventMouseButton.new();down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;down.position=board.cell_position(pair[0])+Vector2(36,36)
	var up:=InputEventMouseButton.new();up.button_index=MOUSE_BUTTON_LEFT;up.pressed=false;up.position=board.cell_position(pair[1])+Vector2(36,36)
	board._gui_input(down);board._gui_input(up);await wait_board(board)
	check(game.session.moves==moves-1,"swipe consumes exactly one move")
	if game.session.finished:
		game.modal_primary();game.modal_primary();board=game.get_node("Board")
	quantity=progress.boosters.hammer;moves=game.session.moves
	game.select_booster("hammer");game.use_targeted("hammer",board.model.legal_moves()[0][0]);await wait_board(board)
	check(progress.boosters.hammer==quantity-1 and game.session.moves==moves,"hammer is consumed once without using a move")
	# Force terminal boundaries to verify result, reward, retry and continuation wiring.
	if game.get_node("Modal").visible: game.get_node("Modal").hide()
	game.session.finished=false;game.session.score=game.session.level.score_goal;game.session.moves=5;game.on_settled()
	check(game.modal_mode=="won" and progress.unlocked>=2,"win unlocks and displays result")
	game.modal_primary();check(game.session.level.number==progress.selected_level,"next level loads requested resource")
	check(game.get_node("TopBar/Title").text=="Level %d"%game.session.level.number,"next level heading refreshes")
	game.modal_primary();game.session.score=0;game.session.moves=0;game.on_settled()
	check(game.modal_mode=="lost","exhausted moves shows loss")
	prior=progress.coins;game.modal_primary()
	check(game.session.moves==5 and progress.coins==prior-100 and game.continued,"one paid continue adds five moves")
	game.session.moves=0;game.on_settled();game.modal_primary()
	check(game.modal_mode=="intro" and not game.continued,"retry starts fresh")
	app.queue_free();await process_frame;await process_frame
	print("UI TESTS: %d checks, %d failures" %[checks,failures]);quit(1 if failures else 0)
