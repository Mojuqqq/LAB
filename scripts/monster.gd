extends CharacterBody2D


@export var speed: float = 80.0
@export var attack_damage: int = 1
@export var attack_interval: float = 1.0


@onready var attack_area: Area2D = $AttackArea
@onready var change_direction_timer: Timer = $ChangeDirectionTimer
@onready var attack_timer: Timer = $AttackTimer


var move_direction: Vector2 = Vector2.ZERO
var player: Node2D = null
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)

	change_direction_timer.timeout.connect(_on_change_direction_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	attack_timer.wait_time = attack_interval

	choose_random_direction()


func _physics_process(_delta: float) -> void:
	if player:
		velocity = Vector2.ZERO
	else:
		velocity = move_direction * speed

	move_and_slide()

	if get_slide_collision_count() > 0 and not player:
		choose_random_direction()


func choose_random_direction() -> void:
	var directions := [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	move_direction = directions[rng.randi_range(0, directions.size() - 1)]

	change_direction_timer.wait_time = rng.randf_range(0.8, 2.5)
	change_direction_timer.start()


func _on_change_direction_timer_timeout() -> void:
	if player:
		return

	choose_random_direction()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player = body

	attack_timer.start()

	attack_player()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body != player:
		return

	player = null

	attack_timer.stop()

	choose_random_direction()


func _on_attack_timer_timeout() -> void:
	attack_player()


func attack_player() -> void:
	if not player:
		return

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	else:
		print("Монстр атакует игрока!")
