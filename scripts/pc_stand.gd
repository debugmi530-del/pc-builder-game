extends Node3D

@export var stand_index: int = 0

var pc_mesh: MeshInstance3D
var monitor_mesh: MeshInstance3D
var glow_light: OmniLight3D
var stand_label: Label3D
var collision_shape: CollisionShape3D

var color_timer: float = 0.0
const COLOR_CHANGE_INTERVAL: float = 2.5
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
	_build_stand()
	add_to_group("interactable")
	GameManager.pc_placed_on_stand.connect(_on_stand_changed)
	GameManager.pc_removed_from_stand.connect(_on_stand_changed)
	_refresh_state()

func _build_stand() -> void:
	# Base (table)
	var base_body = StaticBody3D.new()
	add_child(base_body)
	var base_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1.4, 0.9, 0.8)
	base_mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.22, 0.25)
	mat.roughness = 0.8
	base_mesh.set_surface_override_material(0, mat)
	base_mesh.position = Vector3(0, 0.45, 0)
	base_body.add_child(base_mesh)
	var base_col = CollisionShape3D.new()
	var base_shape = BoxShape3D.new()
	base_shape.size = Vector3(1.4, 0.9, 0.8)
	base_col.shape = base_shape
	base_col.position = Vector3(0, 0.45, 0)
	base_body.add_child(base_col)

	# PC case mesh
	pc_mesh = MeshInstance3D.new()
	var pc_box = BoxMesh.new()
	pc_box.size = Vector3(0.22, 0.44, 0.46)
	pc_mesh.mesh = pc_box
	var pc_mat = StandardMaterial3D.new()
	pc_mat.albedo_color = Color(0.15, 0.15, 0.18)
	pc_mat.metallic = 0.4
	pc_mat.roughness = 0.6
	pc_mesh.set_surface_override_material(0, pc_mat)
	pc_mesh.position = Vector3(-0.45, 1.12, 0)
	pc_mesh.visible = false
	add_child(pc_mesh)

	# Monitor mesh
	monitor_mesh = MeshInstance3D.new()
	var mon_box = BoxMesh.new()
	mon_box.size = Vector3(0.62, 0.38, 0.04)
	monitor_mesh.mesh = mon_box
	var mon_mat = StandardMaterial3D.new()
	mon_mat.albedo_color = Color(0.05, 0.05, 0.05)
	mon_mat.emission_enabled = true
	mon_mat.emission = Color(0.0, 0.8, 1.0)
	mon_mat.emission_energy_multiplier = 2.0
	monitor_mesh.set_surface_override_material(0, mon_mat)
	monitor_mesh.position = Vector3(0.1, 1.12, -0.3)
	monitor_mesh.visible = false
	add_child(monitor_mesh)

	# Glow light
	glow_light = OmniLight3D.new()
	glow_light.light_color = Color(0.0, 0.8, 1.0)
	glow_light.light_energy = 2.0
	glow_light.omni_range = 2.5
	glow_light.position = Vector3(0.1, 1.2, -0.2)
	glow_light.visible = false
	add_child(glow_light)

	# Label3D above stand
	stand_label = Label3D.new()
	stand_label.text = "Пустой стенд"
	stand_label.font_size = 28
	stand_label.position = Vector3(0, 1.7, 0)
	stand_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stand_label.modulate = Color(0.9, 0.95, 1.0)
	add_child(stand_label)

	# Interaction area
	var area = Area3D.new()
	add_child(area)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 1.8
	shape.height = 2.5
	col.shape = shape
	col.position = Vector3(0, 1.25, 0)
	area.add_child(col)

func _process(delta: float) -> void:
	if not is_on:
		return
	color_timer += delta
	if color_timer >= COLOR_CHANGE_INTERVAL:
		color_timer = 0.0
		color_index = (color_index + 1) % MONITOR_COLORS.size()
		_update_monitor_color()

func _refresh_state() -> void:
	if stand_index >= GameManager.stands.size():
		return
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		pc_mesh.visible = false
		monitor_mesh.visible = false
		glow_light.visible = false
		stand_label.text = "🔒 " + GameManager.format_money(GameManager.stand_unlock_costs[stand_index])
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
		stand_label.text = "[E] Поставить ПК"

func _update_monitor_color() -> void:
	if not monitor_mesh:
		return
	var color = MONITOR_COLORS[color_index]
	var mat = monitor_mesh.get_active_material(0)
	if mat and mat is StandardMaterial3D:
		mat.emission = color
		mat.emission_energy_multiplier = 3.0
	glow_light.light_color = color
	glow_light.light_energy = 2.0

func interact() -> void:
	if stand_index >= GameManager.stands.size():
		return
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		_try_unlock()
		return
	if stand["pc"] != null:
		_remove_pc()
	else:
		_show_place_menu()

func get_interact_text() -> String:
	if stand_index >= GameManager.stands.size():
		return ""
	var stand = GameManager.stands[stand_index]
	if not stand["unlocked"]:
		return "[E] Открыть: " + GameManager.format_money(GameManager.stand_unlock_costs[stand_index])
	if stand["pc"] != null:
		return "[E] Снять ПК (" + stand["pc"]["name"] + ")"
	return "[E] Поставить ПК"

func _try_unlock() -> void:
	GameManager.unlock_next_stand()
	_refresh_state()

func _show_place_menu() -> void:
	if GameManager.built_pcs.is_empty():
		return
	var first_pc = GameManager.built_pcs[0]
	if GameManager.place_pc_on_stand(stand_index, first_pc):
		GameManager.remove_built_pc(first_pc["id"])
		TutorialManager.advance("place_on_stand")

func _remove_pc() -> void:
	var pc = GameManager.remove_pc_from_stand(stand_index)
	if not pc.is_empty():
		GameManager.built_pcs.append(pc)

func _on_stand_changed(idx: int) -> void:
	if idx == stand_index:
		_refresh_state()
