extends SceneTree
var failures: int=0
var checks: int=0
func check(value: bool,message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func _init() -> void: call_deferred("run")
func run() -> void:
	var progress=root.get_node("Progress")
	progress.coins=777;progress.unlocked=42;progress.stars={"1":3};progress.scores={"1":12345};progress.boosters={"hammer":5,"shuffle":4,"nova":3};progress.owned=["Lagoon","Starlight"];progress.skin="Starlight";progress.settings.sound=false
	progress.save()
	check(FileAccess.file_exists("user://progress.json"),"save created")
	progress.coins=0;progress.unlocked=1;progress.stars={};progress.skin="Lagoon";progress.settings.sound=true
	progress.load_progress()
	check(progress.coins==777 and progress.unlocked==42,"currency and unlock restored")
	check(progress.stars["1"]==3 and progress.scores["1"]==12345,"ratings and scores restored")
	check(progress.skin=="Starlight" and not progress.settings.sound,"cosmetic and settings restored")
	check(progress.boosters.hammer==5,"inventory restored")
	progress.save()
	var file:=FileAccess.open("user://progress.json",FileAccess.WRITE);file.store_string("{broken json");file.close()
	progress.coins=0;progress.load_progress()
	check(progress.coins==777,"backup recovers corrupt save")
	progress.save()
	file=FileAccess.open("user://progress.json",FileAccess.WRITE);file.store_string("{broken again");file.close()
	progress.coins=0;progress.load_progress()
	check(progress.coins==777,"saving after recovery preserves valid backup")
	progress.save()
	print("SAVE TESTS: %d checks, %d failures" %[checks,failures]);quit(1 if failures else 0)
