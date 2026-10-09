extends Control
signal back_pressed
signal wallet_pressed
@export var title: String = "Adventure"
func _ready() -> void:
	%Title.text = title
	%Back.pressed.connect(func(): back_pressed.emit())
	%Wallet.pressed.connect(func(): wallet_pressed.emit())
	Progress.changed.connect(refresh)
	refresh()
func refresh() -> void:
	%Balance.text = str(Progress.coins)
