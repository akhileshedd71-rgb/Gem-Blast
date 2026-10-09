extends Node
signal changed
const SAVE_PATH := "user://progress.json"
var coins: int = 350
var unlocked: int = 1
var stars: Dictionary = {}
var scores: Dictionary = {}
var boosters: Dictionary = {"hammer": 3, "shuffle": 2, "nova": 1}
var owned: Array = ["Lagoon"]
var skin: String = "Lagoon"
var settings: Dictionary = {"music": true, "sound": true, "haptics": true, "reduced_motion": false}
var daily: String = ""
var selected_level: int = 1
var attempts: Dictionary = {}
var persistence_enabled: bool = true

func _ready() -> void:
	load_progress()

func load_progress() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".bak"]:
		if not FileAccess.file_exists(path): continue
		var parser := JSON.new()
		if parser.parse(FileAccess.get_file_as_string(path)) != OK: continue
		var data = parser.data
		if not data is Dictionary or data.get("version", 0) != 1: continue
		coins = clampi(int(data.get("coins", 350)), 0, 999999)
		unlocked = clampi(int(data.get("unlocked", 1)), 1, 200)
		if data.get("stars") is Dictionary: stars = data.stars
		if data.get("scores") is Dictionary: scores = data.scores
		if data.get("boosters") is Dictionary:
			for key in boosters: boosters[key] = clampi(int(data.boosters.get(key, 0)), 0, 999)
		if data.get("owned") is Array:
			for item in data.owned:
				if item in ["Rose Quartz", "Starlight"] and item not in owned: owned.append(item)
		if data.get("skin", "Lagoon") in owned: skin = data.get("skin", "Lagoon")
		if data.get("settings") is Dictionary:
			for key in settings:
				if data.settings.get(key) is bool: settings[key] = data.settings[key]
		daily = str(data.get("daily", ""))
		return

func save() -> void:
	changed.emit()
	if not persistence_enabled: return
	var data := {"version": 1, "coins": coins, "unlocked": unlocked, "stars": stars, "scores": scores, "boosters": boosters, "owned": owned, "skin": skin, "settings": settings, "daily": daily}
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null: push_warning("Could not save progress"); return
	file.store_string(JSON.stringify(data)); file.close()
	if FileAccess.file_exists(SAVE_PATH):
		var previous := JSON.new()
		if previous.parse(FileAccess.get_file_as_string(SAVE_PATH)) == OK and previous.data is Dictionary and previous.data.get("version", 0) == 1:
			DirAccess.copy_absolute(SAVE_PATH, SAVE_PATH + ".bak")
	var error := DirAccess.rename_absolute(SAVE_PATH + ".tmp", SAVE_PATH)
	if error != OK: push_warning("Could not finalize progress save")

func complete(number: int, rating: int, score: int) -> int:
	var key := str(number)
	var previous := int(stars.get(key, 0))
	var reward := (100 if previous == 0 else 0) + maxi(0, rating - previous) * 25
	stars[key] = maxi(previous, rating)
	scores[key] = maxi(int(scores.get(key, 0)), score)
	coins += reward
	unlocked = maxi(unlocked, mini(200, number + 1))
	save()
	return reward

func spend(amount: int) -> bool:
	if amount < 0 or coins < amount: return false
	coins -= amount; save(); return true

func use_booster(kind: String) -> bool:
	if int(boosters.get(kind, 0)) <= 0: return false
	boosters[kind] -= 1; save(); return true

func buy_booster(kind: String, cost: int) -> bool:
	if not boosters.has(kind) or not spend(cost): return false
	boosters[kind] += 1; save(); return true

func equip(item: String, price: int) -> bool:
	if item not in owned:
		if not spend(price): return false
		owned.append(item)
	skin = item; save(); return true

func daily_available() -> bool:
	return daily != Time.get_date_string_from_system(true)

func claim_daily() -> bool:
	if not daily_available(): return false
	daily = Time.get_date_string_from_system(true)
	coins += 120; save(); return true

func star_total() -> int:
	var total := 0
	for value in stars.values(): total += clampi(int(value), 0, 3)
	return total
