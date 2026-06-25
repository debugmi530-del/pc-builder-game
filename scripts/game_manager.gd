extends Node

signal money_changed(new_amount: float)
signal income_changed(new_income: float)
signal stand_unlocked(stand_index: int)
signal pc_placed_on_stand(stand_index: int)
signal pc_removed_from_stand(stand_index: int)

const STARTING_MONEY: float = 500.0
const MAX_STANDS: int = 20

var money: float = STARTING_MONEY
var income_per_second: float = 0.0
var stands: Array = []
var built_pcs: Array = []
var workshop_level: int = 1
var workshop_upgrade_costs: Array = [500.0, 1500.0, 4000.0, 10000.0, 25000.0]
var workshop_assembly_slots: Array = [1, 2, 3, 4, 5, 6]
var stand_unlock_costs: Array = [
	0.0, 1000.0, 3000.0, 7000.0, 15000.0,
	30000.0, 60000.0, 120000.0, 250000.0, 500000.0,
	1000000.0, 2000000.0, 4000000.0, 8000000.0, 15000000.0,
	30000000.0, 60000000.0, 120000000.0, 250000000.0, 500000000.0
]
var unlocked_stands: int = 1

var income_timer: float = 0.0
var save_timer: float = 0.0
const AUTO_SAVE_INTERVAL: float = 30.0

func _ready() -> void:
	_init_stands()

func _init_stands() -> void:
	for i in MAX_STANDS:
		stands.append({
			"index": i,
			"unlocked": i == 0,
			"pc": null,
			"income": 0.0
		})

func _process(delta: float) -> void:
	income_timer += delta
	if income_timer >= 1.0:
		income_timer = 0.0
		_collect_income()

	save_timer += delta
	if save_timer >= AUTO_SAVE_INTERVAL:
		save_timer = 0.0
		SaveManager.save_game()

func _collect_income() -> void:
	if income_per_second > 0:
		add_money(income_per_second)

func add_money(amount: float) -> void:
	money += amount
	money_changed.emit(money)

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func can_afford(amount: float) -> bool:
	return money >= amount

func recalculate_income() -> void:
	income_per_second = 0.0
	for stand in stands:
		if stand["pc"] != null:
			income_per_second += stand["income"]
	income_changed.emit(income_per_second)

func place_pc_on_stand(stand_index: int, pc_data: Dictionary) -> bool:
	if stand_index < 0 or stand_index >= MAX_STANDS:
		return false
	if not stands[stand_index]["unlocked"]:
		return false
	if stands[stand_index]["pc"] != null:
		return false

	stands[stand_index]["pc"] = pc_data
	stands[stand_index]["income"] = _calculate_pc_income(pc_data)
	recalculate_income()
	pc_placed_on_stand.emit(stand_index)
	SaveManager.save_game()
	return true

func remove_pc_from_stand(stand_index: int) -> Dictionary:
	if stand_index < 0 or stand_index >= MAX_STANDS:
		return {}
	var pc = stands[stand_index]["pc"]
	if pc == null:
		return {}
	stands[stand_index]["pc"] = null
	stands[stand_index]["income"] = 0.0
	recalculate_income()
	pc_removed_from_stand.emit(stand_index)
	SaveManager.save_game()
	return pc

func _calculate_pc_income(pc_data: Dictionary) -> float:
	var base = 0.0
	var components = pc_data.get("components", {})

	if "cpu" in components:
		base += ComponentDatabase.get_component(components["cpu"]).get("income_value", 0.0)
	if "motherboard" in components:
		base += ComponentDatabase.get_component(components["motherboard"]).get("income_value", 0.0)
	if "cooling" in components:
		base += ComponentDatabase.get_component(components["cooling"]).get("income_value", 0.0)
	if "psu" in components:
		base += ComponentDatabase.get_component(components["psu"]).get("income_value", 0.0)
	if "case" in components:
		base += ComponentDatabase.get_component(components["case"]).get("income_value", 0.0)

	for ram in components.get("ram", []):
		base += ComponentDatabase.get_component(ram).get("income_value", 0.0)
	for storage in components.get("storage", []):
		base += ComponentDatabase.get_component(storage).get("income_value", 0.0)
	for gpu in components.get("gpu", []):
		base += ComponentDatabase.get_component(gpu).get("income_value", 0.0)

	return base

func unlock_next_stand() -> bool:
	if unlocked_stands >= MAX_STANDS:
		return false
	var cost = stand_unlock_costs[unlocked_stands]
	if not spend_money(cost):
		return false
	stands[unlocked_stands]["unlocked"] = true
	unlocked_stands += 1
	stand_unlocked.emit(unlocked_stands - 1)
	SaveManager.save_game()
	return true

func get_next_stand_cost() -> float:
	if unlocked_stands >= MAX_STANDS:
		return -1.0
	return stand_unlock_costs[unlocked_stands]

func upgrade_workshop() -> bool:
	if workshop_level >= workshop_upgrade_costs.size():
		return false
	var cost = workshop_upgrade_costs[workshop_level - 1]
	if not spend_money(cost):
		return false
	workshop_level += 1
	SaveManager.save_game()
	return true

func get_workshop_upgrade_cost() -> float:
	if workshop_level > workshop_upgrade_costs.size():
		return -1.0
	return workshop_upgrade_costs[workshop_level - 1]

func get_assembly_slots() -> int:
	return workshop_assembly_slots[min(workshop_level - 1, workshop_assembly_slots.size() - 1)]

func add_built_pc(pc_data: Dictionary) -> void:
	built_pcs.append(pc_data)
	SaveManager.save_game()

func remove_built_pc(pc_id: String) -> Dictionary:
	for i in built_pcs.size():
		if built_pcs[i].get("id", "") == pc_id:
			var pc = built_pcs[i]
			built_pcs.remove_at(i)
			return pc
	return {}

func format_money(amount: float) -> String:
	if amount >= 1_000_000_000:
		return "%.1fМлрд ₽" % (amount / 1_000_000_000)
	elif amount >= 1_000_000:
		return "%.1fМлн ₽" % (amount / 1_000_000)
	elif amount >= 1_000:
		return "%.1fТыс ₽" % (amount / 1_000)
	else:
		return "%.0f ₽" % amount

func new_game() -> void:
	money = STARTING_MONEY
	income_per_second = 0.0
	stands.clear()
	built_pcs.clear()
	workshop_level = 1
	unlocked_stands = 1
	_init_stands()
	Inventory.clear()
	TutorialManager.reset()
	money_changed.emit(money)
	income_changed.emit(income_per_second)
