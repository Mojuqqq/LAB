extends Control


@onready var btn_start: Button = $Panel/VBoxContainer/BtnStart
@onready var btn_settings: Button = $Panel/VBoxContainer/BtnSettings
@onready var btn_exit: Button = $Panel/VBoxContainer/BtnExit


func _ready() -> void:
	btn_start.pressed.connect(
		_on_start_pressed
	)

	btn_settings.pressed.connect(
		_on_settings_pressed
	)

	btn_exit.pressed.connect(
		_on_exit_pressed
	)


func _on_start_pressed() -> void:
	# Старт теперь открывает экран улучшений.
	get_tree().change_scene_to_file(
		"res://scenes/ui/upgrades.tscn"
	)


func _on_settings_pressed() -> void:
	print("Настройки будут добавлены позже")


func _on_exit_pressed() -> void:
	get_tree().quit()
