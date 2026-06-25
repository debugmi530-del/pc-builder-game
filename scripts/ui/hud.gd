extends CanvasLayer

var money_label: Label
var income_label: Label
var tutorial_panel: PanelContainer
var tutorial_label: Label
var notification_label: Label

var notification_timer: float = 0.0

func _ready() -> void:
	_build_ui()
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.income_changed.connect(_on_income_changed)
	TutorialManager.step_changed.connect(_on_tutorial_step)
	TutorialManager.tutorial_complete.connect(_on_tutorial_complete)
	_on_money_changed(GameManager.money)
	_on_income_changed(GameManager.income_per_second)
	if not TutorialManager.is_complete:
		tutorial_panel.visible = true
		tutorial_label.text = TutorialManager.get_current_text()

func _build_ui() -> void:
	# Top bar — money and income
	var top_bar = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.55)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	top_bar.add_theme_stylebox_override("panel", style)
	top_bar.set_anchor_and_offset(SIDE_LEFT, 0.0, 20)
	top_bar.set_anchor_and_offset(SIDE_TOP, 0.0, 20)
	top_bar.set_anchor_and_offset(SIDE_RIGHT, 0.0, 420)
	top_bar.set_anchor_and_offset(SIDE_BOTTOM, 0.0, 80)
	add_child(top_bar)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	top_bar.add_child(hbox)

	money_label = Label.new()
	money_label.text = "💰 500 ₽"
	money_label.add_theme_font_size_override("font_size", 22)
	money_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	hbox.add_child(money_label)

	income_label = Label.new()
	income_label.text = "+0 ₽/сек"
	income_label.add_theme_font_size_override("font_size", 18)
	income_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	hbox.add_child(income_label)

	# Tutorial panel (bottom)
	tutorial_panel = PanelContainer.new()
	var tut_style = StyleBoxFlat.new()
	tut_style.bg_color = Color(0.05, 0.05, 0.15, 0.88)
	tut_style.set_corner_radius_all(10)
	tut_style.border_width_top = 2
	tut_style.border_color = Color(0.3, 0.6, 1.0, 0.9)
	tut_style.content_margin_left = 20
	tut_style.content_margin_right = 20
	tut_style.content_margin_top = 14
	tut_style.content_margin_bottom = 14
	tutorial_panel.add_theme_stylebox_override("panel", tut_style)
	tutorial_panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -340)
	tutorial_panel.set_anchor_and_offset(SIDE_TOP, 1.0, -140)
	tutorial_panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 340)
	tutorial_panel.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -20)
	tutorial_panel.visible = false
	add_child(tutorial_panel)

	var tut_margin = MarginContainer.new()
	tutorial_panel.add_child(tut_margin)

	tutorial_label = Label.new()
	tutorial_label.text = ""
	tutorial_label.add_theme_font_size_override("font_size", 18)
	tutorial_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_margin.add_child(tutorial_label)

	# Notification label (center top)
	notification_label = Label.new()
	notification_label.set_anchor_and_offset(SIDE_LEFT, 0.5, -300)
	notification_label.set_anchor_and_offset(SIDE_TOP, 0.0, 95)
	notification_label.set_anchor_and_offset(SIDE_RIGHT, 0.5, 300)
	notification_label.set_anchor_and_offset(SIDE_BOTTOM, 0.0, 135)
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.add_theme_font_size_override("font_size", 20)
	notification_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	notification_label.visible = false
	add_child(notification_label)

	# Crosshair
	var crosshair = Label.new()
	crosshair.set_anchor_and_offset(SIDE_LEFT, 0.5, -10)
	crosshair.set_anchor_and_offset(SIDE_TOP, 0.5, -10)
	crosshair.set_anchor_and_offset(SIDE_RIGHT, 0.5, 10)
	crosshair.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 10)
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 24)
	crosshair.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(crosshair)

func _process(delta: float) -> void:
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_label.visible = false

func _on_money_changed(amount: float) -> void:
	if money_label:
		money_label.text = "💰 " + GameManager.format_money(amount)

func _on_income_changed(income: float) -> void:
	if income_label:
		income_label.text = "+" + GameManager.format_money(income) + "/сек"

func _on_tutorial_step(_step: int, text: String) -> void:
	if tutorial_label:
		tutorial_panel.visible = true
		tutorial_label.text = text

func _on_tutorial_complete() -> void:
	if tutorial_panel:
		tutorial_panel.visible = false
	show_notification("Туториал завершён! Теперь ты профессионал!")

func show_notification(text: String, duration: float = 3.0) -> void:
	if notification_label:
		notification_label.text = text
		notification_label.visible = true
		notification_timer = duration
