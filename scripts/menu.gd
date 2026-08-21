extends Control   # если корень menu — Control, иначе поменяйте на Panel или Node2D

@onready var btn_exit = $Panel/VBoxContainer/BtnExit

func _ready():
	if btn_exit:
		btn_exit.pressed.connect(_on_exit_pressed)
		print("Кнопка выхода найдена и подключена")  # для проверки
	else:
		print("ОШИБКА: кнопка BtnExit не найдена по пути $Panel/VBoxContainer/BtnExit")

func _on_exit_pressed():
	print("Нажата кнопка выхода!")  # проверка
	get_tree().quit()
