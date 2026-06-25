extends Node3D

@export var stand_index: int = 0

@onready var pc_mesh: MeshInstance3D = $PCMesh
@onready var monitor_mesh: MeshInstance3D = $MonitorMesh
@onready var glow_light: OmniLight3D = $GlowLight
@onready var interaction_area: Area3D = $InteractionArea
@onready var stand_label: Label3D = $StandLabel

var color_timer: float = 0.0
const COLOR_CHANGE_INTERVAL: float = 2.0
const MONITOR_COLORS = [
	Color(0.0, 0.8, 1.0),
	Color(0.0, 1.0, 0.4),
	Color(1.0, 0.5, 0.0),
	Color(1.0, 0.0, 0.6),
	Color(0.5, 0.0, 1.0),
	Color(1.0, 1.0, 0.0),
]
var color_index: int = 0
var is_on: bool = false

func _ready() -> void:
	GameManager.pc_placed_on_stand.connect(_on_stand_changed)
	GameManager.pc_removed_from_stand.connect(_on_stand_changed)
	_refresh_state()

func _process(delta: float) -> void:
	if not is_on:
		return
	color_timer += delta
	if color_timer >= COLOR_CHANGE_INTERVAL:
		color_timer = 0.0
		color_index = (color_index + 1) % MONITOR_COLORS.size()
		_update_monitor_color()

func _refresh_state() -> void:
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		pc_mesh.visible = false
		monitor_mesh.visible = false
		glow_light.visible = false
		stand_label.text = "🔒 Заблокировано\n%s" % GameManager.format_money(GameManager.stand_unlock_costs[stand_index])
		is_on = false
		return

	if stand["pc"] != null:
		pc_mesh.visible = true
		monitor_mesh.visible = true
		glow_light.visible = true
		is_on = true
		stand_label.text = stand["pc"]["name"] + "\n+" + GameManager.format_money(stand["income"]) + "/сек"
		_update_monitor_color()
	else:
		pc_mesh.visible = false
		monitor_mesh.visible = false
		glow_light.visible = false
		is_on = false
		stand_label.text = "Пустой стенд\n[E] поставить ПК"

func _update_monitor_color() -> void:
	var color = MONITOR_COLORS[color_index]
	var mat = monitor_mesh.get_active_material(0)
	if mat and mat is StandardMaterial3D:
		mat.emission = color
		mat.emission_energy_multiplier = 3.0
	glow_light.light_color = color
	glow_light.light_energy = 2.0

func interact() -> void:
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		_try_unlock()
		return
	if stand["pc"] != null:
		_show_stand_menu()
	else:
		_show_place_pc_menu()

func get_interact_text() -> String:
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		return "[E] Разблокировать (%s)" % GameManager.format_money(GameManager.stand_unlock_costs[stand_index])
	if stand["pc"] != null:
		return "[E] Управление стендом"
	return "[E] Поставить ПК"

func _try_unlock() -> void:
	if GameManager.unlock_next_stand():
		_refresh_state()
	else:
		pass

func _show_place_pc_menu() -> void:
	var tree = get_tree()
	var game_scene = tree.current_scene
	var stand_menu = game_scene.get_node_or_null("StandMenu")
	if stand_menu:
		stand_menu.open_for_stand(stand_index)
	TutorialManager.advance("place_on_stand")

func _show_stand_menu() -> void:
	var tree = get_tree()
	var game_scene = tree.current_scene
	var stand_menu = game_scene.get_node_or_null("StandMenu")
	if stand_menu:
		stand_menu.open_manage(stand_index)

func _on_stand_changed(idx: int) -> void:
	if idx == stand_index:
		_refresh_state()
