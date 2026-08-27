extends Area2D


signal collected


var is_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if not body.is_in_group("player"):
		return

	is_collected = true

	collected.emit()

	queue_free()
