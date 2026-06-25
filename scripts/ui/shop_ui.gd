extends Control

var category_list: ItemList
var item_list: VBoxContainer
var scroll: ScrollContainer

const CATEGORIES = [
	ComponentDatabase.ComponentType.CPU,
	ComponentDatabase.ComponentType.MOTHERBOARD,
	ComponentDatabase.ComponentType.RAM,
	ComponentDatabase.ComponentType.STORAGE,
	ComponentDatabase.ComponentType.GPU,
	ComponentDatabase.ComponentType.COOLING,
	ComponentDatabase.ComponentType.PSU,
	ComponentDatabase.ComponentType.CASE,
]

func _ready() -> void:
	_build_ui()
	_refresh_items()

func _build_ui() -> void:
	# Background overlay
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	add_child(bg)

	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -560)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -380)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 560)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 380)
	add_child(panel)

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Title row
	var title_row = HBoxContainer.new()
	vbox.add_child(title_row)

	var title = Label.new()
	title.text = "🛒  Магазин комплектующих"
	title.add_theme_font_size_override("font_size", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	var close_btn = Button.new()
	close_btn.text = "✕ Закрыть"
	close_btn.custom_minimum_size = Vector2(120, 40)
	close_btn.pressed.connect(_on_close)
	title_row.add_child(close_btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Content row
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)

	# Left — categories
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(210, 0)
	hbox.add_child(left_panel)

	var left_vbox = VBoxContainer.new()
	left_panel.add_child(left_vbox)

	var cat_label = Label.new()
	cat_label.text = "Категории:"
	cat_label.add_theme_font_size_override("font_size", 16)
	left_vbox.add_child(cat_label)

	category_list = ItemList.new()
	category_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for type in CATEGORIES:
		category_list.add_item(ComponentDatabase.get_type_name(type))
	category_list.select(0)
	category_list.item_selected.connect(_on_category_selected)
	left_vbox.add_child(category_list)

	# Right — items
	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(scroll)

	item_list = VBoxContainer.new()
	item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_list.add_theme_constant_override("separation", 8)
	scroll.add_child(item_list)

func _on_category_selected(index: int) -> void:
	_refresh_items(CATEGORIES[index])

func _refresh_items(type: ComponentDatabase.ComponentType = CATEGORIES[0]) -> void:
	if not item_list:
		return
	for child in item_list.get_children():
		child.queue_free()

	var components = ComponentDatabase.get_all_by_type(type)
	for comp in components:
		item_list.add_child(_create_item_row(comp))

func _create_item_row(comp: Dictionary) -> Control:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.16, 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	panel.add_child(hbox)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_lbl = Label.new()
	name_lbl.text = comp["name"]
	name_lbl.add_theme_font_size_override("font_size", 17)
	info.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = comp["description"]
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	desc_lbl.add_theme_font_size_override("font_size", 13)
	info.add_child(desc_lbl)

	if comp["income_value"] > 0:
		var income_lbl = Label.new()
		income_lbl.text = "Доход: +" + GameManager.format_money(comp["income_value"]) + "/сек"
		income_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		income_lbl.add_theme_font_size_override("font_size", 13)
		info.add_child(income_lbl)

	var right = VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(right)

	var price_lbl = Label.new()
	price_lbl.text = GameManager.format_money(comp["price"])
	price_lbl.add_theme_font_size_override("font_size", 19)
	price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(price_lbl)

	var qty_lbl = Label.new()
	qty_lbl.text = "В инвентаре: %d" % Inventory.get_quantity(comp["id"])
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	qty_lbl.add_theme_font_size_override("font_size", 12)
	right.add_child(qty_lbl)

	var buy_btn = Button.new()
	buy_btn.text = "Купить"
	buy_btn.custom_minimum_size = Vector2(130, 40)
	var can = GameManager.can_afford(comp["price"])
	buy_btn.disabled = not can
	if not can:
		buy_btn.text = "Нет денег"
	buy_btn.pressed.connect(_buy_component.bind(comp["id"]))
	right.add_child(buy_btn)

	return panel

func _buy_component(component_id: String) -> void:
	var comp = ComponentDatabase.get_component(component_id)
	if comp.is_empty():
		return
	if GameManager.spend_money(comp["price"]):
		Inventory.add_item(component_id)
		var cat_idx = category_list.get_selected_items()
		_refresh_items(CATEGORIES[cat_idx[0]] if cat_idx.size() > 0 else CATEGORIES[0])
		TutorialManager.advance(_get_tutorial_action(comp["type"]))

func _get_tutorial_action(type: ComponentDatabase.ComponentType) -> String:
	match type:
		ComponentDatabase.ComponentType.CPU: return "buy_cpu"
		ComponentDatabase.ComponentType.MOTHERBOARD: return "buy_motherboard"
		ComponentDatabase.ComponentType.RAM: return "buy_ram"
		ComponentDatabase.ComponentType.STORAGE: return "buy_storage"
		ComponentDatabase.ComponentType.GPU: return "buy_gpu"
		ComponentDatabase.ComponentType.COOLING: return "buy_cooling"
		ComponentDatabase.ComponentType.PSU: return "buy_psu"
		ComponentDatabase.ComponentType.CASE: return "buy_case"
	return ""

func _on_close() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	TutorialManager.advance("enter_shop")
