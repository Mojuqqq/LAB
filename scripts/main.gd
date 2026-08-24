extends Node2D

func _ready():
	var level = GameManager.current_level
	print("Загружен уровень: ", level)
	# Тут можно менять сложность, расположение объектов в зависимости от уровня
