extends Node2D


@onready var exit: Area2D = $Objects/Exit
@onready var game_over_popup: CanvasLayer = $GameOverPopup


var keys_left: int = 0


func _ready() -> void:
	var keys := get_tree().get_nodes_in_group("keys")

	keys_left = keys.size()

	print("Ключей на уровне: ", keys_left)

	for key in keys:
		key.collected.connect(_on_key_collected)

	exit.level_completed.connect(_on_level_completed)

	if keys_left == 0:
		exit.open()


func _on_key_collected() -> void:
	keys_left -= 1

	print("Осталось ключей: ", keys_left)

	if keys_left <= 0:
		exit.open()


func _on_level_completed() -> void:
	game_over_popup.show()

	get_tree().paused = true
