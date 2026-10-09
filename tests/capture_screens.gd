extends SceneTree
var app: Control
var output_dir: String = "user://captures"
func _init() -> void: call_deferred("run")
func capture(name: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output_dir.path_join(name + ".png"))
func run() -> void:
	if not OS.get_environment("GEM_BLAST_CAPTURE_DIR").is_empty(): output_dir = OS.get_environment("GEM_BLAST_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output_dir)
	root.size=Vector2i(450,800)
	root.content_scale_size=Vector2i(720,1280)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	app=load("res://scenes/main.tscn").instantiate(); root.add_child(app)
	await create_timer(1.8).timeout
	await capture("home")
	for page in ["map","shop","wardrobe","settings","game"]:
		app.show_screen(page)
		await capture(page)
		if page=="game":
			app.current.modal_primary()
			await capture("board")
			var board=app.current.get_node("Board")
			var move=board.model.legal_moves()[0]
			board.attempt_swap(move[0],move[1])
			await create_timer(3).timeout
			await capture("after-move")
	root.get_node("Audio").music.stop()
	await create_timer(0.3).timeout
	app.queue_free(); await process_frame; await process_frame
	quit()
