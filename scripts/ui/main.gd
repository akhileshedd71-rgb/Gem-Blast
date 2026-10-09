extends Control
const SCREENS := {"splash": preload("res://scenes/ui/splash.tscn"), "home": preload("res://scenes/ui/home.tscn"), "map": preload("res://scenes/ui/level_map.tscn"), "game": preload("res://scenes/ui/gameplay.tscn"), "shop": preload("res://scenes/ui/shop.tscn"), "wardrobe": preload("res://scenes/ui/wardrobe.tscn"), "settings": preload("res://scenes/ui/settings.tscn")}
var current: BaseScreen
var page: String = ""
func _ready() -> void:
	get_tree().auto_accept_quit = false
	%ToastTimer.timeout.connect(func(): %Toast.hide())
	show_screen("splash")
func show_screen(destination: String) -> void:
	if not SCREENS.has(destination): return
	if is_instance_valid(current):
		%ScreenHost.remove_child(current); current.queue_free()
	page = destination
	current = SCREENS[destination].instantiate()
	current.navigate.connect(show_screen)
	current.notification.connect(show_toast)
	%ScreenHost.add_child(current)
	if not Progress.settings.reduced_motion:
		current.modulate.a = 0
		create_tween().tween_property(current, "modulate:a", 1.0, 0.22)
func show_toast(message: String) -> void:
	%Message.text = message
	%Toast.show(); %ToastTimer.start()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: Progress.save(); get_tree().quit()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST: back()
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): back(); get_viewport().set_input_as_handled()
func back() -> void:
	if page == "game": current.pause_game()
	elif page != "home" and page != "splash": show_screen("home")
