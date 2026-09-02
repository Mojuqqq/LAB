extends Control

# Ссылки на кнопки (пути соответствуют вашей структуре)
@onready var btn_start = $Panel/VBoxContainer/BtnStart
@onready var btn_settings = $Panel/VBoxContainer/BtnSettings
@onready var btn_exit = $Panel/VBoxContainer/BtnExit

func _ready():
	# Подключаем сигналы нажатия
	btn_start.pressed.connect(_on_start_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

# Обработчик кнопки "Старт" - переход на экран выбора уровней
func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

# Обработчик кнопки "Настройки" (заглушка)
func _on_settings_pressed():
	print("Настройки будут добавлены позже")

# Обработчик кнопки "Выход" - закрытие игры
func _on_exit_pressed():
	get_tree().quit()
