extends BaseScreen
const PRODUCT := preload("res://scenes/ui/product.tscn")
const STYLES := [["Lagoon", "Aqua skies & cool crystal shores", 0, 1], ["Rose Quartz", "Pink skies & lavender daydreams", 350, 0], ["Starlight", "Periwinkle skies & moonlit magic", 600, 2]]
func _ready() -> void:
	connect_top()
	for item in STYLES:
		var row := PRODUCT.instantiate(); %Styles.add_child(row); row.custom_minimum_size = Vector2(624, 172)
		row.get_node("Art").texture = load("res://assets/art/gem_%d.svg" % item[3])
		row.get_node("Name").text = item[0]; row.get_node("Description").text = item[1]
		row.get_node("Buy").pressed.connect(choose.bind(item[0], item[2]))
	Progress.changed.connect(refresh); refresh()
func choose(item: String, price: int) -> void:
	if Progress.equip(item, price): Audio.play("tap"); notify(item + " equipped. Looking brilliant!")
	else: notify("Keep collecting coins to unlock this look.")
func refresh() -> void:
	for i in range(%Styles.get_child_count()):
		var row := %Styles.get_child(i)
		var name_value: String = STYLES[i][0]
		row.get_node("Buy").text = "Using" if Progress.skin == name_value else ("Equip" if name_value in Progress.owned else str(STYLES[i][2]))
		row.get_node("Buy").disabled = Progress.skin == name_value
		row.get_node("Owned").text = "In your collection" if name_value in Progress.owned else "%d coins • unlock forever" % STYLES[i][2]
