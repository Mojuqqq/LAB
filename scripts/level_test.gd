extends Node2D


@export var level_time: float = 60.0
@export var key_time_bonus: float = 5.0


@onready var exit: Area2D = $Objects/Exit
@onready var level_timer: Timer = $LevelTimer
@onready var timer_label: Label = $HUD/TopCenter/TimerLabel
@onready var time_bonus_label: Label = $HUD/TopCenter/TimeBonusLabel
@onready var game_over_popup: CanvasLayer = $GameOverPopup
@onready var player = $Player
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var key_counter: Label = $HUD/KeyCounter


var level_ended: bool = false
var time_bonus_tween: Tween

var total_keys: int = 0
var keys_collected: int = 0
var keys_left: int = 0


func _ready() -> void:
	var keys := get_tree().get_nodes_in_group("keys")

	total_keys = keys.size()
	keys_left = total_keys
	keys_collected = 0

	update_key_counter()

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
	
	player.health_changed.connect(
	_on_player_health_changed
)

	player.died.connect(
	_on_player_died
)

	health_bar.min_value = 0
	health_bar.max_value = player.max_health
	health_bar.value = player.health

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

	keys_collected += 1
	keys_left -= 1

	update_key_counter()

	add_bonus_time(key_time_bonus)
	show_time_bonus(key_time_bonus)

	print(
		"Ключей собрано: ",
		keys_collected,
		"/",
		total_keys
	)

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
	timer_label.text = "00:00"

	show_game_over()


func _on_level_completed() -> void:
	if level_ended:
		return

	level_ended = true
	level_timer.stop()

	get_tree().change_scene_to_file(
		"res://scenes/ui/level_select.tscn"
	)
	
func _on_player_health_changed(
	current_health: int,
	max_health: int
) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	
func update_key_counter() -> void:
	key_counter.text = "%d / %d" % [
		keys_collected,
		total_keys
	]

func _on_player_died() -> void:
	show_game_over()


func show_game_over() -> void:
	if level_ended:
		return

	level_ended = true

	level_timer.stop()

	game_over_popup.visible = true

	get_tree().paused = true
