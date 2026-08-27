extends Node2D


@onready var exit: Area2D = $Objects/Exit


var keys_left: int = 0


func _ready() -> void:
	var keys := get_tree().get_nodes_in_group("keys")

	keys_left = keys.size()

	print("Ключей на уровне: ", keys_left)

	for key in keys:
		key.collected.connect(_on_key_collected)

	if keys_left == 0:
		exit.open()


func _on_key_collected() -> void:
	keys_left -= 1

	print("Осталось ключей: ", keys_left)

	if keys_left <= 0:
		exit.open()
