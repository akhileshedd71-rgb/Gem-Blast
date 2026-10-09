class_name Campaign
extends RefCounted
const TOTAL := 200
const WORLDS := ["Crystal Cove", "Bubblegum Bay", "Sunbeam Gardens", "Amethyst Forest", "Cloudberry Peaks", "Moonstone Lagoon", "Coral Carnival", "Starlight Palace", "Aurora Falls", "Prism Summit"]
const COLORS := [Color("8ce1de"), Color("f1b9dc"), Color("ffe398"), Color("ceb5ed"), Color("addbe9"), Color("9fbfed"), Color("ffc0b4"), Color("c6b1e9"), Color("a3e7d9"), Color("dbc0fa")]
static func level(number: int) -> LevelData:
	return load("res://resources/levels/level_%03d.tres" % clampi(number, 1, TOTAL)) as LevelData
