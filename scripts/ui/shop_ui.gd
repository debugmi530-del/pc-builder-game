extends Control

@onready var category_list: ItemList = $HSplit/Left/CategoryList
@onready var item_list: VBoxContainer = $HSplit/Right/ScrollContainer/ItemList
@onready var close_btn: Button = $CloseBtn
@onready var title_label: Label = $TitleLabel

var item_btn_scene: PackedScene = null
var current_type: ComponentDatabase.ComponentType = ComponentDatabase.ComponentType.CPU

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
	for type in CATEGORIES:
		category_list.add_item(ComponentDatabase.get_type_name(type))
	category_list.select(0)
	category_list.item_selected.connect(_on_category_selected)
	close_btn.pressed.connect(_on_close)
	_refresh_items()

func _on_category_selected(index: int) -> void:
	current_type = CATEGORIES[index]
	_refresh_items()

func _refresh_items() -> void:
	for child in item_list.get_children():
		child.queue_free()

	var components = ComponentDatabase.get_all_by_type(current_type)
	for comp in components:
		var row = _create_item_row(comp)
		item_list.add_child(row)

func _create_item_row(comp: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 80)

	var hbox = HBoxContainer.new()
	panel.add_child(hbox)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_lbl = Label.new()
	name_lbl.text = comp["name"]
	name_lbl.add_theme_font_size_override("font_size", 18)
	info.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = comp["description"]
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info.add_child(desc_lbl)

	var income_lbl = Label.new()
	if comp["income_value"] > 0:
		income_lbl.text = "Доход: +" + GameManager.format_money(comp["income_value"]) + "/сек"
		income_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	else:
		income_lbl.text = "Корпус — влияет на вид сборки"
		income_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.4))
	info.add_child(income_lbl)

	var right = VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right)

	var price_lbl = Label.new()
	price_lbl.text = GameManager.format_money(comp["price"])
	price_lbl.add_theme_font_size_override("font_size", 20)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(price_lbl)

	var buy_btn = Button.new()
	buy_btn.text = "Купить"
	buy_btn.custom_minimum_size = Vector2(120, 40)
	if not GameManager.can_afford(comp["price"]):
		buy_btn.disabled = true
		buy_btn.text = "Нет денег"
	buy_btn.pressed.connect(_buy_component.bind(comp["id"], buy_btn))
	right.add_child(buy_btn)

	var qty_lbl = Label.new()
	qty_lbl.text = "В инвентаре: %d" % Inventory.get_quantity(comp["id"])
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	right.add_child(qty_lbl)

	return panel

func _buy_component(component_id: String, btn: Button) -> void:
	var comp = ComponentDatabase.get_component(component_id)
	if comp.is_empty():
		return
	if GameManager.spend_money(comp["price"]):
		Inventory.add_item(component_id)
		_refresh_items()
		AudioManager.play_sfx(null)
		TutorialManager.advance(_get_tutorial_action(comp["type"]))
	else:
		btn.text = "Нет денег"
		await get_tree().create_timer(1.0).timeout
		btn.text = "Купить"

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
	TutorialManager.advance("enter_shop")
