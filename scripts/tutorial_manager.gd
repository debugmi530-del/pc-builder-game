extends Node

signal step_changed(step: int, text: String)
signal tutorial_complete()

var is_complete: bool = false
var current_step: int = 0

const STEPS = [
	{"text": "Добро пожаловать в PC Builder!\nНажми WASD для движения, мышь для осмотра.", "action": "move"},
	{"text": "Иди в магазин — большое здание впереди.", "action": "enter_shop"},
	{"text": "Купи любой ПРОЦЕССОР — нажми [E] на стойке с процессорами.", "action": "buy_cpu"},
	{"text": "Теперь купи МАТЕРИНСКУЮ ПЛАТУ.", "action": "buy_motherboard"},
	{"text": "Купи ОПЕРАТИВНУЮ ПАМЯТЬ.", "action": "buy_ram"},
	{"text": "Купи НАКОПИТЕЛЬ (HDD, SSD или M.2).", "action": "buy_storage"},
	{"text": "Купи ВИДЕОКАРТУ.", "action": "buy_gpu"},
	{"text": "Купи ОХЛАЖДЕНИЕ (кулер или СВО).", "action": "buy_cooling"},
	{"text": "Купи БЛОК ПИТАНИЯ.", "action": "buy_psu"},
	{"text": "Купи КОРПУС — последняя деталь!", "action": "buy_case"},
	{"text": "Отлично! Иди в МАСТЕРСКУЮ.", "action": "enter_workshop"},
	{"text": "Нажми [E] на рабочем столе чтобы начать сборку.", "action": "open_workshop"},
	{"text": "Установи все комплектующие в слоты.\nНажимай на слот и выбирай деталь.", "action": "assemble_pc"},
	{"text": "Дай имя своему ПК и нажми 'Собрать'!", "action": "name_pc"},
	{"text": "Теперь иди в ЗАЛ СТЕНДОВ.", "action": "enter_stands"},
	{"text": "Нажми [E] на стенд и выбери свой ПК.\nСмотри как он начинает приносить деньги!", "action": "place_on_stand"},
	{"text": "Поздравляем! Ты освоил основы.\nТеперь покупай лучшие комплектующие и открывай новые стенды!", "action": "complete"},
]

func _ready() -> void:
	pass

func start() -> void:
	if is_complete:
		return
	current_step = 0
	_show_step()

func _show_step() -> void:
	if current_step >= STEPS.size():
		_complete()
		return
	var step = STEPS[current_step]
	step_changed.emit(current_step, step["text"])

func advance(action: String = "") -> void:
	if is_complete:
		return
	if action != "" and current_step < STEPS.size():
		if STEPS[current_step]["action"] != action:
			return
	current_step += 1
	_show_step()

func _complete() -> void:
	is_complete = true
	tutorial_complete.emit()

func reset() -> void:
	is_complete = false
	current_step = 0

func get_current_text() -> String:
	if current_step < STEPS.size():
		return STEPS[current_step]["text"]
	return ""
