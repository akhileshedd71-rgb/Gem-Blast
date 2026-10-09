class_name BaseScreen
extends Control
signal navigate(destination: String)
signal notification(message: String)
func go(destination: String) -> void:
	Audio.play("tap")
	navigate.emit(destination)
func notify(message: String) -> void:
	notification.emit(message)
func connect_top(back: String = "home") -> void:
	%TopBar.back_pressed.connect(go.bind(back))
	%TopBar.wallet_pressed.connect(go.bind("shop"))
