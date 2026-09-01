extends Node2D


@export var level_time: float = 60.0
@export var key_time_bonus: float = 5.0


@onready var exit: Area2D = $Objects/Exit
@onready var level_timer: Timer = $LevelTimer
@onready var timer_label: Label = $HUD/TimerLabel
@onready var time_bonus_label: Label = $HUD/TimeBonusLabel
@onready var game_over_popup: CanvasLayer = $GameOverPopup


var keys_left: int = 0
var level_ended: bool = false
var time_bonus_tween: Tween


func _ready() -> void:
	var keys := get_tree().get_nodes_in_group("keys")

	keys_left = keys.size()

	print("Ключей на уровне: ", keys_left)

	for key in keys:
		key.collected.connect(_on_key_collected)

	exit.level_completed.connect(_on_level_completed)

	if keys_left == 0:
		exit.open()

	level_timer.wait_time = level_time
	level_timer.one_shot = true
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()

	game_over_popup.visible = false
	time_bonus_label.visible = false

	update_timer_label()


func _process(_delta: float) -> void:
	if level_ended:
		return

	update_timer_label()


func update_timer_label() -> void:
	var time_left: float = maxf(level_timer.time_left, 0.0)
	var total_seconds: int = int(ceil(time_left))

	var minutes: int = int(total_seconds / 60.0)
	var seconds: int = total_seconds % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_key_collected() -> void:
	if level_ended:
		return

	keys_left -= 1

	add_bonus_time(key_time_bonus)
	show_time_bonus(key_time_bonus)

	print("Осталось ключей: ", keys_left)

	if keys_left <= 0:
		exit.open()


func add_bonus_time(seconds: float) -> void:
	var new_time := level_timer.time_left + seconds

	level_timer.start(new_time)

	update_timer_label()


func show_time_bonus(seconds: float) -> void:
	if time_bonus_tween:
		time_bonus_tween.kill()

	time_bonus_label.text = "+%d сек." % int(seconds)
	time_bonus_label.visible = true
	time_bonus_label.modulate.a = 1.0

	var start_position := time_bonus_label.position

	time_bonus_tween = create_tween()

	time_bonus_tween.set_parallel(true)

	time_bonus_tween.tween_property(
		time_bonus_label,
		"position",
		start_position + Vector2(0, -30),
		0.8
	)

	time_bonus_tween.tween_property(
		time_bonus_label,
		"modulate:a",
		0.0,
		0.8
	)

	time_bonus_tween.set_parallel(false)

	time_bonus_tween.tween_callback(
		func():
			time_bonus_label.visible = false
			time_bonus_label.position = start_position
	)


func _on_level_timer_timeout() -> void:
	if level_ended:
		return

	level_ended = true

	timer_label.text = "00:00"

	game_over_popup.visible = true

	get_tree().paused = true


func _on_level_completed() -> void:
	if level_ended:
		return

	level_ended = true
	level_timer.stop()

	get_tree().change_scene_to_file(
		"res://scenes/ui/level_select.tscn"
	)
