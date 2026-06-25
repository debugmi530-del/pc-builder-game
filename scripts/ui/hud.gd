extends CanvasLayer

@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel
@onready var income_label: Label = $MarginContainer/HBoxContainer/IncomeLabel
@onready var zone_label: Label = $ZoneLabel
@onready var tutorial_panel: PanelContainer = $TutorialPanel
@onready var tutorial_label: Label = $TutorialPanel/MarginContainer/TutorialLabel
@onready var notification_label: Label = $NotificationLabel

var notification_timer: float = 0.0

func _ready() -> void:
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.income_changed.connect(_on_income_changed)
	TutorialManager.step_changed.connect(_on_tutorial_step)
	TutorialManager.tutorial_complete.connect(_on_tutorial_complete)
	_on_money_changed(GameManager.money)
	_on_income_changed(GameManager.income_per_second)
	tutorial_panel.visible = not TutorialManager.is_complete
	if not TutorialManager.is_complete:
		tutorial_label.text = TutorialManager.get_current_text()

func _process(delta: float) -> void:
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_label.visible = false

func _on_money_changed(amount: float) -> void:
	money_label.text = "💰 " + GameManager.format_money(amount)

func _on_income_changed(income: float) -> void:
	income_label.text = "+" + GameManager.format_money(income) + "/сек"

func _on_tutorial_step(step: int, text: String) -> void:
	tutorial_panel.visible = true
	tutorial_label.text = text

func _on_tutorial_complete() -> void:
	tutorial_panel.visible = false
	show_notification("Туториал завершён! Теперь ты профессионал!")

func show_notification(text: String, duration: float = 3.0) -> void:
	notification_label.text = text
	notification_label.visible = true
	notification_timer = duration

func set_zone_name(zone: String) -> void:
	zone_label.text = zone
