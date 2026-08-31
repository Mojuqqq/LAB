extends Node2D


@export var level_time: float = 60.0


@onready var exit: Area2D = $Objects/Exit
@onready var level_timer: Timer = $LevelTimer
@onready var timer_label: Label = $HUD/TimerLabel
@onready var game_over_popup: CanvasLayer = $GameOverPopup


var keys_left: int = 0
var level_ended: bool = false


func _ready() -> void:
	var keys := get_tree().get_nodes_in_group("keys")

	keys_left = keys.size()

	print("Ключей на уровне: ", keys_left)

	for key in keys:
		key.collected.connect(_on_key_collected)

	if keys_left == 0:
		exit.open()

	# Настраиваем и запускаем таймер.
	level_timer.wait_time = level_time
	level_timer.one_shot = true
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()

	game_over_popup.visible = false

	update_timer_label()


func _process(_delta: float) -> void:
	if level_ended:
		return

	update_timer_label()


func update_timer_label() -> void:
	var time_left := max(level_timer.time_left, 0.0)

	var total_seconds := int(ceil(time_left))

	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_key_collected() -> void:
	if level_ended:
		return

	keys_left -= 1

	print("Осталось ключей: ", keys_left)

	if keys_left <= 0:
		exit.open()


func _on_level_timer_timeout() -> void:
	if level_ended:
		return

	level_ended = true

	timer_label.text = "00:00"

	game_over_popup.visible = true

	get_tree().paused = true
