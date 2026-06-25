extends Control

signal pc_assembled(pc_data: Dictionary)

var slots_container: GridContainer
var assemble_btn: Button
var status_label: Label
var pc_name_edit: LineEdit
var picker_panel: Control
var picker_list: VBoxContainer

var current_build: Dictionary = {
	"cpu": "", "motherboard": "", "ram": [],
	"storage": [], "gpu": [], "cooling": "", "psu": "", "case": ""
}
var slot_buttons: Dictionary = {}
var selecting_slot: String = ""
var selecting_multi_index: int = -1

const SLOT_CONFIG = [
	{"key": "cpu",         "label": "Процессор",        "multi": false},
	{"key": "motherboard", "label": "Мат. плата",        "multi": false},
	{"key": "ram",         "label": "ОЗУ",               "multi": true, "max": 4},
	{"key": "storage",     "label": "Накопитель",        "multi": true, "max": 4},
	{"key": "gpu",         "label": "Видеокарта",        "multi": true, "max": 2},
	{"key": "cooling",     "label": "Охлаждение",        "multi": false},
	{"key": "psu",         "label": "Блок питания",      "multi": false},
	{"key": "case",        "label": "Корпус",            "multi": false},
]

func _ready() -> void:
	_build_ui()
	_reset_build()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.72)
	add_child(bg)

	var main_panel = PanelContainer.new()
	main_panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -580)
	main_panel.set_anchor_and_offset(SIDE_TOP, 0.5, -400)
	main_panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 580)
	main_panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 400)
	add_child(main_panel)

	var outer_vbox = VBoxContainer.new()
	main_panel.add_child(outer_vbox)

	var title_row = HBoxContainer.new()
	outer_vbox.add_child(title_row)

	var title = Label.new()
	title.text = "🔧  Мастерская — сборка ПК"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	var cancel_btn = Button.new()
	cancel_btn.text = "✕ Отмена"
	cancel_btn.custom_minimum_size = Vector2(110, 38)
	cancel_btn.pressed.connect(_on_cancel)
	title_row.add_child(cancel_btn)

	outer_vbox.add_child(HSeparator.new())

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(scroll)

	slots_container = GridContainer.new()
	slots_container.columns = 4
	slots_container.add_theme_constant_override("h_separation", 10)
	slots_container.add_theme_constant_override("v_separation", 10)
	slots_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(slots_container)

	outer_vbox.add_child(HSeparator.new())

	status_label = Label.new()
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	outer_vbox.add_child(status_label)

	var bottom_row = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 12)
	outer_vbox.add_child(bottom_row)

	var name_lbl = Label.new()
	name_lbl.text = "Имя ПК:"
	name_lbl.add_theme_font_size_override("font_size", 17)
	bottom_row.add_child(name_lbl)

	pc_name_edit = LineEdit.new()
	pc_name_edit.placeholder_text = "Например: Мой первый ПК"
	pc_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pc_name_edit.add_theme_font_size_override("font_size", 17)
	bottom_row.add_child(pc_name_edit)

	assemble_btn = Button.new()
	assemble_btn.text = "✅ Собрать!"
	assemble_btn.custom_minimum_size = Vector2(150, 48)
	assemble_btn.add_theme_font_size_override("font_size", 18)
	assemble_btn.disabled = true
	assemble_btn.pressed.connect(_on_assemble)
	bottom_row.add_child(assemble_btn)

	# Component picker panel
	picker_panel = PanelContainer.new()
	picker_panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -300)
	picker_panel.set_anchor_and_offset(SIDE_TOP, 0.5, -280)
	picker_panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 300)
	picker_panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 280)
	picker_panel.visible = false
	add_child(picker_panel)

	var picker_vbox = VBoxContainer.new()
	picker_panel.add_child(picker_vbox)

	var picker_title_row = HBoxContainer.new()
	picker_vbox.add_child(picker_title_row)

	var picker_title = Label.new()
	picker_title.text = "Выбери комплектующее:"
	picker_title.add_theme_font_size_override("font_size", 18)
	picker_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker_title_row.add_child(picker_title)

	var close_picker_btn = Button.new()
	close_picker_btn.text = "✕"
	close_picker_btn.custom_minimum_size = Vector2(40, 36)
	close_picker_btn.pressed.connect(func(): picker_panel.visible = false)
	picker_title_row.add_child(close_picker_btn)

	var picker_scroll = ScrollContainer.new()
	picker_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picker_vbox.add_child(picker_scroll)

	picker_list = VBoxContainer.new()
	picker_list.add_theme_constant_override("separation", 6)
	picker_scroll.add_child(picker_list)

func _reset_build() -> void:
	current_build = {
		"cpu": "", "motherboard": "", "ram": [],
		"storage": [], "gpu": [], "cooling": "", "psu": "", "case": ""
	}
	slot_buttons.clear()
	for child in slots_container.get_children():
		child.queue_free()
	_build_slots()
	if pc_name_edit:
		pc_name_edit.text = ""
	if assemble_btn:
		assemble_btn.disabled = true
	if status_label:
		status_label.text = "Установи все обязательные компоненты"

func _build_slots() -> void:
	for cfg in SLOT_CONFIG:
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)

		var lbl = Label.new()
		lbl.text = cfg["label"]
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
		vbox.add_child(lbl)

		if cfg["multi"]:
			var max_count = cfg.get("max", 4)
			for i in max_count:
				var btn = Button.new()
				btn.custom_minimum_size = Vector2(150, 46)
				btn.text = "[ пусто ]"
				btn.add_theme_font_size_override("font_size", 12)
				var slot_key = cfg["key"] + "_" + str(i)
				btn.pressed.connect(_open_picker.bind(cfg["key"], i))
				vbox.add_child(btn)
				slot_buttons[slot_key] = btn
		else:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(150, 46)
			btn.text = "[ пусто ]"
			btn.add_theme_font_size_override("font_size", 12)
			btn.pressed.connect(_open_picker.bind(cfg["key"], -1))
			vbox.add_child(btn)
			slot_buttons[cfg["key"]] = btn

		slots_container.add_child(vbox)

func _open_picker(slot_key: String, index: int) -> void:
	selecting_slot = slot_key
	selecting_multi_index = index
	var type = _get_type_for_slot(slot_key)

	for child in picker_list.get_children():
		child.queue_free()

	var items = Inventory.get_items_by_type(type)
	if items.is_empty():
		var lbl = Label.new()
		lbl.text = "Нет этой детали в инвентаре.\nСначала купи её в магазине!"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		picker_list.add_child(lbl)
	else:
		for item in items:
			var comp = item["component"]
			var btn = Button.new()
			btn.text = "%s  (x%d)  — %s" % [comp["name"], item["quantity"], GameManager.format_money(comp["income_value"]) + "/сек"]
			btn.custom_minimum_size = Vector2(0, 48)
			btn.add_theme_font_size_override("font_size", 15)
			btn.pressed.connect(_select_component.bind(comp["id"]))
			picker_list.add_child(btn)

	picker_panel.visible = true

func _select_component(comp_id: String) -> void:
	if not Inventory.has_item(comp_id):
		return
	Inventory.remove_item(comp_id)

	var key = selecting_slot
	var idx = selecting_multi_index

	if idx < 0:
		if current_build[key] != "":
			Inventory.add_item(current_build[key])
		current_build[key] = comp_id
		slot_buttons[key].text = ComponentDatabase.get_component(comp_id)["name"]
	else:
		if idx < current_build[key].size():
			Inventory.add_item(current_build[key][idx])
			current_build[key][idx] = comp_id
		else:
			current_build[key].append(comp_id)
		slot_buttons[key + "_" + str(idx)].text = ComponentDatabase.get_component(comp_id)["name"]

	picker_panel.visible = false
	_update_status()
	TutorialManager.advance("assemble_pc")

func _get_type_for_slot(key: String) -> ComponentDatabase.ComponentType:
	match key:
		"cpu": return ComponentDatabase.ComponentType.CPU
		"motherboard": return ComponentDatabase.ComponentType.MOTHERBOARD
		"ram": return ComponentDatabase.ComponentType.RAM
		"storage": return ComponentDatabase.ComponentType.STORAGE
		"gpu": return ComponentDatabase.ComponentType.GPU
		"cooling": return ComponentDatabase.ComponentType.COOLING
		"psu": return ComponentDatabase.ComponentType.PSU
		"case": return ComponentDatabase.ComponentType.CASE
	return ComponentDatabase.ComponentType.CPU

func _update_status() -> void:
	var missing = []
	if current_build["cpu"] == "": missing.append("Процессор")
	if current_build["motherboard"] == "": missing.append("Мат. плата")
	if current_build["cooling"] == "": missing.append("Охлаждение")
	if current_build["psu"] == "": missing.append("БП")
	if current_build["case"] == "": missing.append("Корпус")
	if current_build["ram"].is_empty(): missing.append("ОЗУ")
	if current_build["storage"].is_empty(): missing.append("Накопитель")

	if missing.is_empty():
		status_label.text = "✅ Всё установлено — можно собирать!"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		assemble_btn.disabled = false
	else:
		status_label.text = "Не хватает: " + ", ".join(missing)
		status_label.add_theme_color_override("font_color", Color.YELLOW)
		assemble_btn.disabled = true

func _on_assemble() -> void:
	var name = pc_name_edit.text.strip_edges()
	if name.is_empty():
		name = "ПК #%d" % (GameManager.built_pcs.size() + 1)
	var pc = {
		"id": str(Time.get_unix_time_from_system()) + str(randi()),
		"name": name,
		"components": current_build.duplicate(true)
	}
	GameManager.add_built_pc(pc)
	pc_assembled.emit(pc)
	TutorialManager.advance("name_pc")
	_reset_build()
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _return_to_inventory() -> void:
	for key in ["cpu","motherboard","cooling","psu","case"]:
		if current_build[key] != "":
			Inventory.add_item(current_build[key])
	for key in ["ram","storage","gpu"]:
		for id in current_build[key]:
			Inventory.add_item(id)

func _on_cancel() -> void:
	_return_to_inventory()
	_reset_build()
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func open_for_assembly() -> void:
	_reset_build()
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	TutorialManager.advance("open_workshop")
