extends Node

signal item_added(component_id: String)
signal item_removed(component_id: String)
signal inventory_changed()

var items: Dictionary = {}

func add_item(component_id: String, quantity: int = 1) -> void:
	if component_id in items:
		items[component_id] += quantity
	else:
		items[component_id] = quantity
	item_added.emit(component_id)
	inventory_changed.emit()

func remove_item(component_id: String, quantity: int = 1) -> bool:
	if not has_item(component_id, quantity):
		return false
	items[component_id] -= quantity
	if items[component_id] <= 0:
		items.erase(component_id)
	item_removed.emit(component_id)
	inventory_changed.emit()
	return true

func has_item(component_id: String, quantity: int = 1) -> bool:
	return items.get(component_id, 0) >= quantity

func get_quantity(component_id: String) -> int:
	return items.get(component_id, 0)

func get_all_items() -> Array:
	var result = []
	for id in items:
		var comp = ComponentDatabase.get_component(id)
		if not comp.is_empty():
			result.append({
				"component": comp,
				"quantity": items[id]
			})
	return result

func get_items_by_type(type: ComponentDatabase.ComponentType) -> Array:
	var result = []
	for id in items:
		var comp = ComponentDatabase.get_component(id)
		if not comp.is_empty() and comp["type"] == type:
			result.append({
				"component": comp,
				"quantity": items[id]
			})
	return result

func clear() -> void:
	items.clear()
	inventory_changed.emit()

func to_dict() -> Dictionary:
	return items.duplicate()

func from_dict(data: Dictionary) -> void:
	items = data.duplicate()
	inventory_changed.emit()
