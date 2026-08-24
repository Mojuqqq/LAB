extends Control

# Используем @onready с проверкой пути
@onready var levels_container = $FadeMask/ScrollContainer/VBoxContainer
@onready var back_button = $Panel/ButtonBack   # предположим, что кнопка "Назад" называется ButtonBack

var total_levels = 50

func _ready():
	# Проверяем, найден ли контейнер
	if levels_container == null:
		print("ОШИБКА: levels_container не найден! Проверьте путь $ScrollContainer/VBoxContainer")
		return  # выходим, чтобы не было ошибки add_child
	
	# Генерируем кнопки
	for i in range(1, total_levels + 1):
		var btn = Button.new()
		btn.text = "Уровень " + str(i)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 0)
		btn.add_theme_font_size_override("font_size", 48)
		btn.pressed.connect(_on_level_button_pressed.bind(i))
		levels_container.add_child(btn)   # теперь точно не null
	
	# Подключаем кнопку "Назад"
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	else:
		print("ОШИБКА: кнопка 'Назад' не найдена. Проверьте путь $ButtonBack")

func _on_level_button_pressed(level_number):
	print("Выбран уровень: ", level_number)
	# Записываем в GameManager (если он создан)
	# GameManager.current_level = level_number
	get_tree().change_scene_to_file("res://scenes/main.tscn")  # или ваша игровая сцена

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
