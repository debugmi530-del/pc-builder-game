extends Node

const SAVE_PATH = "user://savegame.dat"

func save_game() -> void:
	var data = {
		"money": GameManager.money,
		"workshop_level": GameManager.workshop_level,
		"unlocked_stands": GameManager.unlocked_stands,
		"stands": _serialize_stands(),
		"built_pcs": GameManager.built_pcs.duplicate(true),
		"inventory": Inventory.to_dict(),
		"tutorial_done": TutorialManager.is_complete,
		"tutorial_step": TutorialManager.current_step
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		return false
	_apply_save(parsed)
	return true

func _apply_save(data: Dictionary) -> void:
	GameManager.money = data.get("money", 500.0)
	GameManager.workshop_level = data.get("workshop_level", 1)
	GameManager.unlocked_stands = data.get("unlocked_stands", 1)
	GameManager.built_pcs = data.get("built_pcs", [])
	Inventory.from_dict(data.get("inventory", {}))
	TutorialManager.is_complete = data.get("tutorial_done", false)
	TutorialManager.current_step = data.get("tutorial_step", 0)
	_deserialize_stands(data.get("stands", []))
	GameManager.recalculate_income()
	GameManager.money_changed.emit(GameManager.money)

func _serialize_stands() -> Array:
	var result = []
	for stand in GameManager.stands:
		result.append({
			"index": stand["index"],
			"unlocked": stand["unlocked"],
			"pc": stand["pc"],
			"income": stand["income"]
		})
	return result

func _deserialize_stands(data: Array) -> void:
	for i in data.size():
		if i < GameManager.stands.size():
			GameManager.stands[i]["unlocked"] = data[i].get("unlocked", i == 0)
			GameManager.stands[i]["pc"] = data[i].get("pc", null)
			GameManager.stands[i]["income"] = data[i].get("income", 0.0)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
