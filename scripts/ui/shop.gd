extends BaseScreen
const PRODUCT := preload("res://scenes/ui/product.tscn")
const ITEMS := [
	["hammer", "Crystal hammer", "Break one gem, ice tile or stone.", 120],
	["shuffle", "Lucky shuffle", "Refresh the board. Keep your moves.", 90],
	["nova", "Color nova", "Tap a gem to clear every gem of its color.", 180]]
func _ready() -> void:
	connect_top()
	for button in [%CoinSoon, %CoinMedium, %CoinLarge]:
		button.pressed.connect(func(): notify("Coin packs are coming soon. No purchase has been made."))
	for item in ITEMS:
		var row := PRODUCT.instantiate(); %Products.add_child(row); row.custom_minimum_size = Vector2(624, 172)
		row.get_node("Art").texture = load("res://assets/art/" + item[0] + ".svg")
		row.get_node("Name").text = item[1]; row.get_node("Description").text = item[2]
		row.get_node("Buy").text = str(item[3])
		row.get_node("Buy").icon = preload("res://assets/art/coin.svg")
		row.get_node("Buy").expand_icon = true; row.get_node("Buy").add_theme_constant_override("icon_max_width", 28)
		row.get_node("Buy").pressed.connect(buy.bind(item[0], item[3]))
	Progress.changed.connect(refresh); refresh()
func buy(kind: String, cost: int) -> void:
	if Progress.buy_booster(kind, cost): Audio.play("win"); notify("A little magic added to your collection!")
	else: Audio.play("bad"); notify("More coins needed. Complete levels or collect your daily gift.")
func refresh() -> void:
	for i in range(%Products.get_child_count()):
		%Products.get_child(i).get_node("Owned").text = "In your bag: %d" % Progress.boosters[ITEMS[i][0]]
