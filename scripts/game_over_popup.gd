extends CanvasLayer


@onready var btn_level_select: Button = $Overlay/Panel/VBoxContainer/BtnLevelSelect
@onready var btn_retry: Button = $Overlay/Panel/VBoxContainer/BtnRetry
@onready var btn_exit: Button = $Overlay/Panel/VBoxContainer/BtnExit


func _ready() -> void:
	btn_level_select.pressed.connect(_on_level_select_pressed)
	btn_retry.pressed.connect(_on_retry_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)


func _on_level_select_pressed() -> void:
	get_tree().paused = false

	get_tree().change_scene_to_file(
		"res://scenes/ui/level_select.tscn"
	)


func _on_retry_pressed() -> void:
	get_tree().paused = false

	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	get_tree().quit()
