extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const MOUSE_SENSITIVITY = 0.002
const GRAVITY = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var interact_label: Label = $InteractLabel
@onready var zone_label: Label = $ZoneLabel

var can_move: bool = true
var current_zone: String = "main"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_label.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI/2.1, PI/2.1)

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if can_move:
		var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	_check_interaction()

func _check_interaction() -> void:
	if not raycast.is_colliding():
		interact_label.visible = false
		return

	var collider = raycast.get_collider()
	if collider == null:
		interact_label.visible = false
		return

	if collider.is_in_group("interactable"):
		interact_label.visible = true
		interact_label.text = collider.get_interact_text() if collider.has_method("get_interact_text") else "[E] Взаимодействовать"

		if Input.is_action_just_pressed("ui_interact"):
			collider.interact()
	else:
		interact_label.visible = false

func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector3.ZERO

func teleport_to_zone(zone: String, position: Vector3) -> void:
	current_zone = zone
	global_position = position
	zone_label.text = _get_zone_display_name(zone)

func _get_zone_display_name(zone: String) -> String:
	match zone:
		"shop": return "Магазин"
		"workshop": return "Мастерская"
		"stands": return "Зал стендов"
	return ""
