extends Control

signal pc_assembled(pc_data: Dictionary)

@onready var slots_container: GridContainer = $Panel/VBox/SlotsContainer
@onready var assemble_btn: Button = $Panel/VBox/Bottom/AssembleBtn
@onready var cancel_btn: Button = $Panel/VBox/Bottom/CancelBtn
@onready var pc_name_edit: LineEdit = $Panel/VBox/Bottom/NameEdit
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var component_picker: Control = $ComponentPicker

var current_build: Dictionary = {
	"cpu": "",
	"motherboard": "",
	"ram": [],
	"storage": [],
	"gpu": [],
	"cooling": "",
	"psu": "",
	"case": ""
}
var selecting_slot: String = ""
var slot_buttons: Dictionary = {}

const SLOT_CONFIG = [
	{"key": "cpu",         "label": "Процессор",          "multi": false},
	{"key": "motherboard", "label": "Материнская плата",   "multi": false},
	{"key": "ram",         "label": "ОЗУ",                 "multi": true,  "max": 4},
	{"key": "storage",     "label": "Накопитель",          "multi": true,  "max": 4},
	{"key": "gpu",         "label": "Видеокарта",          "multi": true,  "max": 2},
	{"key": "cooling",     "label": "Охлаждение",          "multi": false},
	{"key": "psu",         "label": "Блок питания",        "multi": false},
	{"key": "case",        "label": "Корпус",              "multi": false},
]

func _ready() -> void:
	_build_slots()
	assemble_btn.pressed.connect(_on_assemble)
	cancel_btn.pressed.connect(_on_cancel)
	component_picker.visible = false

func _build_slots() -> void:
	for cfg in SLOT_CONFIG:
		var vbox = VBoxContainer.new()

		var lbl = Label.new()
		lbl.text = cfg["label"]
		lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(lbl)

		if cfg["multi"]:
			var max_count = cfg.get("max", 4)
			for i in max_count:
				var btn = Button.new()
				btn.custom_minimum_size = Vector2(180, 50)
				btn.text = "— Пусто —"
				var slot_key = cfg["key"] + "_" + str(i)
				btn.pressed.connect(_open_picker.bind(cfg["key"], i))
				vbox.add_child(btn)
				slot_buttons[slot_key] = btn
		else:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(180, 50)
			btn.text = "— Пусто —"
			btn.pressed.connect(_open_picker.bind(cfg["key"], -1))
			vbox.add_child(btn)
			slot_buttons[cfg["key"]] = btn

		slots_container.add_child(vbox)

func _open_picker(slot_key: String, index: int) -> void:
	selecting_slot = slot_key if index < 0 else slot_key + "_" + str(index)
	var type = _get_type_for_slot(slot_key)
	_populate_picker(type, slot_key, index)
	component_picker.visible = true

func _get_type_for_slot(slot_key: String) -> ComponentDatabase.ComponentType:
	match slot_key:
		"cpu": return ComponentDatabase.ComponentType.CPU
		"motherboard": return ComponentDatabase.ComponentType.MOTHERBOARD
		"ram": return ComponentDatabase.ComponentType.RAM
		"storage": return ComponentDatabase.ComponentType.STORAGE
		"gpu": return ComponentDatabase.ComponentType.GPU
		"cooling": return ComponentDatabase.ComponentType.COOLING
		"psu": return ComponentDatabase.ComponentType.PSU
		"case": return ComponentDatabase.ComponentType.CASE
	return ComponentDatabase.ComponentType.CPU

func _populate_picker(type: ComponentDatabase.ComponentType, slot_key: String, index: int) -> void:
	var picker_list = component_picker.get_node("VBox/ScrollContainer/List")
	for c in picker_list.get_children():
		c.queue_free()

	var items = Inventory.get_items_by_type(type)
	if items.is_empty():
		var lbl = Label.new()
		lbl.text = "Нет комплектующих этого типа в инвентаре"
		picker_list.add_child(lbl)
		return

	for item in items:
		var comp = item["component"]
		var btn = Button.new()
		btn.text = "%s  (x%d)" % [comp["name"], item["quantity"]]
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(_select_component.bind(comp["id"], slot_key, index))
		picker_list.add_child(btn)

func _select_component(comp_id: String, slot_key: String, index: int) -> void:
	if not Inventory.has_item(comp_id):
		return
	Inventory.remove_item(comp_id)

	if index < 0:
		if current_build[slot_key] != "":
			Inventory.add_item(current_build[slot_key])
		current_build[slot_key] = comp_id
		slot_buttons[slot_key].text = ComponentDatabase.get_component(comp_id)["name"]
	else:
		if index < current_build[slot_key].size():
			Inventory.add_item(current_build[slot_key][index])
			current_build[slot_key][index] = comp_id
		else:
			current_build[slot_key].append(comp_id)
		slot_buttons[slot_key + "_" + str(index)].text = ComponentDatabase.get_component(comp_id)["name"]

	component_picker.visible = false
	_update_status()
	TutorialManager.advance("assemble_pc")

func _update_status() -> void:
	var missing = []
	if current_build["cpu"] == "": missing.append("Процессор")
	if current_build["motherboard"] == "": missing.append("Материнская плата")
	if current_build["cooling"] == "": missing.append("Охлаждение")
	if current_build["psu"] == "": missing.append("Блок питания")
	if current_build["case"] == "": missing.append("Корпус")
	if current_build["ram"].is_empty(): missing.append("ОЗУ")
	if current_build["storage"].is_empty(): missing.append("Накопитель")

	if missing.is_empty():
		status_label.text = "✅ Все обязательные компоненты установлены!"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		assemble_btn.disabled = false
	else:
		status_label.text = "Не хватает: " + ", ".join(missing)
		status_label.add_theme_color_override("font_color", Color.YELLOW)
		assemble_btn.disabled = true

func _on_assemble() -> void:
	var name = pc_name_edit.text.strip_edges()
	if name == "":
		name = "Мой ПК #%d" % (GameManager.built_pcs.size() + 1)

	var pc_data = {
		"id": str(Time.get_unix_time_from_system()),
		"name": name,
		"components": current_build.duplicate(true)
	}
	GameManager.add_built_pc(pc_data)
	pc_assembled.emit(pc_data)
	TutorialManager.advance("name_pc")
	_reset()
	visible = false

func _reset() -> void:
	current_build = {"cpu":"","motherboard":"","ram":[],"storage":[],"gpu":[],"cooling":"","psu":"","case":""}
	for btn in slot_buttons.values():
		btn.text = "— Пусто —"
	pc_name_edit.text = ""
	status_label.text = ""
	assemble_btn.disabled = true

func _on_cancel() -> void:
	_return_all_to_inventory()
	_reset()
	visible = false

func _return_all_to_inventory() -> void:
	for key in ["cpu","motherboard","cooling","psu","case"]:
		if current_build[key] != "":
			Inventory.add_item(current_build[key])
	for key in ["ram","storage","gpu"]:
		for id in current_build[key]:
			Inventory.add_item(id)
