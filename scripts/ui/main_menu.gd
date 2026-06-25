extends Control

@onready var continue_btn: Button = $CenterContainer/VBoxContainer/ContinueBtn
@onready var new_game_btn: Button = $CenterContainer/VBoxContainer/NewGameBtn
@onready var settings_btn: Button = $CenterContainer/VBoxContainer/SettingsBtn
@onready var quit_btn: Button = $CenterContainer/VBoxContainer/QuitBtn
@onready var settings_panel: Control = $SettingsPanel
@onready var confirm_panel: Control = $ConfirmPanel
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	version_label.text = "v1.0"
	continue_btn.visible = SaveManager.has_save()
	settings_panel.visible = false
	confirm_panel.visible = false
	continue_btn.pressed.connect(_on_continue)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_continue() -> void:
	if SaveManager.load_game():
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_new_game_pressed() -> void:
	if SaveManager.has_save():
		confirm_panel.visible = true
	else:
		_start_new_game()

func _start_new_game() -> void:
	SaveManager.delete_save()
	GameManager.new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings() -> void:
	settings_panel.visible = true

func _on_quit() -> void:
	get_tree().quit()

func _on_confirm_yes() -> void:
	confirm_panel.visible = false
	_start_new_game()

func _on_confirm_no() -> void:
	confirm_panel.visible = false
