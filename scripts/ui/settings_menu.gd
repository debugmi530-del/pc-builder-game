extends Control

@onready var music_slider: HSlider = $Panel/VBox/MusicSection/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SFXSection/SFXSlider
@onready var music_label: Label = $Panel/VBox/MusicSection/ValueLabel
@onready var sfx_label: Label = $Panel/VBox/SFXSection/ValueLabel
@onready var fullscreen_check: CheckButton = $Panel/VBox/DisplaySection/FullscreenCheck
@onready var graphics_preset: OptionButton = $Panel/VBox/GraphicsSection/GraphicsPreset
@onready var shadow_slider: HSlider = $Panel/VBox/GraphicsSection/ShadowSlider
@onready var aa_option: OptionButton = $Panel/VBox/GraphicsSection/AAOption
@onready var render_scale_slider: HSlider = $Panel/VBox/GraphicsSection/RenderScaleSlider
@onready var render_scale_label: Label = $Panel/VBox/GraphicsSection/RenderScaleLabel
@onready var fps_limit_slider: HSlider = $Panel/VBox/GraphicsSection/FPSSlider
@onready var fps_label: Label = $Panel/VBox/GraphicsSection/FPSLabel
@onready var back_btn: Button = $Panel/VBox/BackBtn
@onready var apply_btn: Button = $Panel/VBox/ApplyBtn

const SETTINGS_PATH = "user://settings.dat"

var settings: Dictionary = {
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"fullscreen": true,
	"graphics_preset": 2,
	"shadow_quality": 0.8,
	"antialiasing": 1,
	"render_scale": 1.0,
	"fps_limit": 60
}

func _ready() -> void:
	load_settings()
	_apply_to_ui()
	back_btn.pressed.connect(_on_back)
	apply_btn.pressed.connect(_on_apply)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	graphics_preset.item_selected.connect(_on_graphics_preset)
	render_scale_slider.value_changed.connect(_on_render_scale_changed)
	fps_limit_slider.value_changed.connect(_on_fps_changed)

func _apply_to_ui() -> void:
	music_slider.value = settings["music_volume"]
	sfx_slider.value = settings["sfx_volume"]
	music_label.text = "%d%%" % (settings["music_volume"] * 100)
	sfx_label.text = "%d%%" % (settings["sfx_volume"] * 100)
	fullscreen_check.button_pressed = settings["fullscreen"]
	graphics_preset.selected = settings["graphics_preset"]
	shadow_slider.value = settings["shadow_quality"]
	aa_option.selected = settings["antialiasing"]
	render_scale_slider.value = settings["render_scale"]
	render_scale_label.text = "%d%%" % (settings["render_scale"] * 100)
	fps_limit_slider.value = settings["fps_limit"]
	fps_label.text = "%d FPS" % settings["fps_limit"]

func _on_music_changed(value: float) -> void:
	settings["music_volume"] = value
	music_label.text = "%d%%" % (value * 100)
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	settings["sfx_volume"] = value
	sfx_label.text = "%d%%" % (value * 100)
	AudioManager.set_sfx_volume(value)

func _on_graphics_preset(index: int) -> void:
	settings["graphics_preset"] = index
	match index:
		0:
			settings["shadow_quality"] = 0.3
			settings["antialiasing"] = 0
			settings["render_scale"] = 0.75
		1:
			settings["shadow_quality"] = 0.6
			settings["antialiasing"] = 1
			settings["render_scale"] = 1.0
		2:
			settings["shadow_quality"] = 0.9
			settings["antialiasing"] = 2
			settings["render_scale"] = 1.0
		3:
			settings["shadow_quality"] = 1.0
			settings["antialiasing"] = 3
			settings["render_scale"] = 1.0
	_apply_to_ui()

func _on_render_scale_changed(value: float) -> void:
	settings["render_scale"] = value
	render_scale_label.text = "%d%%" % (value * 100)

func _on_fps_changed(value: float) -> void:
	settings["fps_limit"] = int(value)
	fps_label.text = "%d FPS" % int(value)

func _on_apply() -> void:
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	Engine.max_fps = settings["fps_limit"]
	var viewport = get_viewport()
	viewport.scaling_3d_scale = settings["render_scale"]
	match settings["antialiasing"]:
		0: viewport.msaa_3d = Viewport.MSAA_DISABLED
		1: viewport.msaa_3d = Viewport.MSAA_2X
		2: viewport.msaa_3d = Viewport.MSAA_4X
		3: viewport.msaa_3d = Viewport.MSAA_8X
	save_settings()

func _on_back() -> void:
	visible = false

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed:
		settings.merge(parsed, true)
	_on_apply()
