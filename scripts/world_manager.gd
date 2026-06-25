extends Node3D

const STAND_COLS: int = 5
const STAND_SPACING: float = 3.5
const STANDS_ORIGIN: Vector3 = Vector3(-30, 0, -20)

var shop_ui: Control
var workshop_ui: Control
var stands_root: Node3D
var stand_nodes: Array = []

var player_node: CharacterBody3D

func _ready() -> void:
	await get_tree().process_frame
	player_node = get_tree().current_scene.get_node_or_null("Player")
	_build_world()
	_spawn_stands()
	_build_shop_zone()
	_build_workshop_zone()
	_spawn_ui()
	SaveManager.load_game()
	TutorialManager.start()

func _build_world() -> void:
	# --- SHOP BUILDING ---
	var shop_pos = Vector3(0, 0, -50)
	_make_zone_floor(shop_pos, Vector3(24, 0.3, 20), Color(0.25, 0.3, 0.45))
	_make_label_3d(shop_pos + Vector3(0, 4, 0), "🛒  МАГАЗИН")

	# --- WORKSHOP BUILDING ---
	var ws_pos = Vector3(40, 0, 0)
	_make_zone_floor(ws_pos, Vector3(20, 0.3, 20), Color(0.3, 0.25, 0.2))
	_make_label_3d(ws_pos + Vector3(0, 4, 0), "🔧  МАСТЕРСКАЯ")
	_make_workbench(ws_pos + Vector3(0, 0, 2))

	# --- STANDS AREA label ---
	_make_label_3d(STANDS_ORIGIN + Vector3(STAND_COLS * STAND_SPACING * 0.5, 4, 5), "💻  ЗАЛ СТЕНДОВ")

func _make_zone_floor(pos: Vector3, sz: Vector3, col: Color) -> void:
	var body = StaticBody3D.new()
	body.position = pos
	get_tree().current_scene.add_child(body)
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = sz
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = 0.95
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	var col_shape = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = sz
	col_shape.shape = bshape
	body.add_child(col_shape)

func _make_workbench(pos: Vector3) -> void:
	var bench = StaticBody3D.new()
	bench.position = pos
	bench.add_to_group("interactable")
	get_tree().current_scene.add_child(bench)
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2.0, 0.85, 1.0)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.35, 0.2)
	mat.roughness = 0.9
	mesh.set_surface_override_material(0, mat)
	mesh.position = Vector3(0, 0.425, 0)
	bench.add_child(mesh)
	var col_shape = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = Vector3(2.0, 0.85, 1.0)
	col_shape.shape = bshape
	col_shape.position = Vector3(0, 0.425, 0)
	bench.add_child(col_shape)
	var lbl = Label3D.new()
	lbl.text = "[E] Начать сборку"
	lbl.font_size = 26
	lbl.position = Vector3(0, 1.5, 0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bench.add_child(lbl)
	bench.set_meta("type", "workbench")

func _make_label_3d(pos: Vector3, text: String) -> void:
	var lbl = Label3D.new()
	lbl.text = text
	lbl.font_size = 48
	lbl.position = pos
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.modulate = Color(0.9, 0.95, 1.0)
	get_tree().current_scene.add_child(lbl)

func _build_shop_zone() -> void:
	var area = Area3D.new()
	area.position = Vector3(0, 0.5, -50)
	get_tree().current_scene.add_child(area)
	var col = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = Vector3(24, 4, 20)
	col.shape = bshape
	area.add_child(col)
	area.monitoring = true
	area.body_entered.connect(_on_zone_entered.bind("shop"))
	area.body_exited.connect(_on_zone_exited)
	# Shop display labels
	var types = ["CPU", "MB", "RAM", "SSD", "GPU", "COOL", "PSU", "CASE"]
	for i in types.size():
		var sign = Label3D.new()
		sign.text = types[i]
		sign.font_size = 32
		sign.position = Vector3(-10.5 + i * 3.0, 2.5, -58)
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign.modulate = Color(0.4, 0.85, 1.0)
		get_tree().current_scene.add_child(sign)

func _build_workshop_zone() -> void:
	var area = Area3D.new()
	area.position = Vector3(40, 0.5, 0)
	get_tree().current_scene.add_child(area)
	var col = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = Vector3(20, 4, 20)
	col.shape = bshape
	area.add_child(col)
	area.monitoring = true
	area.body_entered.connect(_on_zone_entered.bind("workshop"))
	area.body_exited.connect(_on_zone_exited)

func _spawn_stands() -> void:
	stands_root = Node3D.new()
	stands_root.name = "StandsRoot"
	get_tree().current_scene.add_child(stands_root)
	for i in GameManager.MAX_STANDS:
		var stand = preload("res://scripts/pc_stand.gd").new()
		stand.name = "Stand_" + str(i)
		stand.stand_index = i
		var row = i / STAND_COLS
		var col = i % STAND_COLS
		stand.position = STANDS_ORIGIN + Vector3(col * STAND_SPACING, 0, row * STAND_SPACING)
		stands_root.add_child(stand)
		stand_nodes.append(stand)

func _spawn_ui() -> void:
	# Shop UI
	var shop_layer = CanvasLayer.new()
	shop_layer.name = "ShopLayer"
	get_tree().current_scene.add_child(shop_layer)

	shop_ui = preload("res://scripts/ui/shop_ui.gd").new()
	shop_ui.name = "ShopUI"
	shop_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_ui.visible = false
	shop_layer.add_child(shop_ui)

	# Workshop UI
	var ws_layer = CanvasLayer.new()
	ws_layer.name = "WorkshopLayer"
	get_tree().current_scene.add_child(ws_layer)

	workshop_ui = preload("res://scripts/ui/workshop_ui.gd").new()
	workshop_ui.name = "WorkshopUI"
	workshop_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	workshop_ui.visible = false
	ws_layer.add_child(workshop_ui)

func _on_zone_entered(body: Node, zone: String) -> void:
	if body is CharacterBody3D:
		match zone:
			"shop":
				shop_ui.visible = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				TutorialManager.advance("enter_shop")
			"workshop":
				workshop_ui.visible = true
				workshop_ui.open_for_assembly()
				TutorialManager.advance("enter_workshop")

func _on_zone_exited(body: Node) -> void:
	if body is CharacterBody3D:
		if shop_ui and shop_ui.visible:
			shop_ui.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if workshop_ui and workshop_ui.visible:
			workshop_ui.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
