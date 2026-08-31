extends Area2D


signal level_completed


var is_open: bool = false
var is_completed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	$Sprite2D.modulate = Color(0.5, 0.5, 0.5)


func open() -> void:
	is_open = true

	$Sprite2D.modulate = Color.WHITE

	print("Выход открыт!")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not is_open:
		print("Сначала собери все ключи!")
		return

	if is_completed:
		return

	is_completed = true

	level_completed.emit()
