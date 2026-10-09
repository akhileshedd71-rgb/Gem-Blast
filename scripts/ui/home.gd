extends BaseScreen
func _ready() -> void:
	%Play.text = "PLAY  •  LEVEL %d" % Progress.unlocked
	%Play.pressed.connect(func(): Progress.selected_level = Progress.unlocked; go("game"))
	%Map.pressed.connect(go.bind("map"))
	%Shop.pressed.connect(go.bind("shop"))
	%Wardrobe.pressed.connect(go.bind("wardrobe"))
	%Settings.pressed.connect(go.bind("settings"))
	%Daily.pressed.connect(claim_gift)
	%Daily.text = "Daily gift" if Progress.daily_available() else "Gift claimed"
	%ProgressLabel.text = "%d / 600 stars  •  200 sparkling levels" % Progress.star_total()
func claim_gift() -> void:
	if Progress.claim_daily():
		Audio.play("win"); %Daily.text = "Gift claimed"
		notify("A gift from Pip! +120 coins. Come back tomorrow.")
	else: notify("Today's gift is collected. A new gift arrives tomorrow!")
