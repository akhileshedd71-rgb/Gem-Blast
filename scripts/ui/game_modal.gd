extends Control
signal primary_pressed
signal secondary_pressed
func _ready() -> void:
	%Primary.pressed.connect(func(): Audio.play("tap"); primary_pressed.emit())
	%Secondary.pressed.connect(func(): Audio.play("tap"); secondary_pressed.emit())
func display(title: String, body: String, primary: String, secondary: String, art: String = "star") -> void:
	%Title.text = title; %Body.text = body; %Primary.text = primary; %Secondary.text = secondary
	%Emblem.texture = load("res://assets/art/" + art + ".svg")
	show()
	%Primary.grab_focus()
