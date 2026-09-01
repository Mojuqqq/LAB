extends CharacterBody2D


enum State {
	WANDER,
	CHASE,
	ATTACK
}


@export var speed: float = 80.0
@export var attack_damage: int = 1
@export var attack_interval: float = 1.0
@export var detection_radius: float = 180.0


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_area: Area2D = $AttackArea
@onready var detection_area: Area2D = $DetectionArea
@onready var wander_timer: Timer = $WanderTimer
@onready var attack_timer: Timer = $AttackTimer


var state: State = State.WANDER
var player: Node2D = null

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)

	wander_timer.timeout.connect(_on_wander_timer_timeout)

	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	call_deferred("choose_wander_target")
	
func _physics_process(_delta: float) -> void:
	match state:
		State.WANDER:
			move_along_navigation()

		State.CHASE:
			chase_player()

		State.ATTACK:
			velocity = Vector2.ZERO

	move_and_slide()
	
func move_along_navigation() -> void:
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_position := navigation_agent.get_next_path_position()

	var direction := global_position.direction_to(next_position)

	velocity = direction * speed
	
func choose_wander_target() -> void:
	if state != State.WANDER:
		return

	var random_offset := Vector2(
		rng.randf_range(-250.0, 250.0),
		rng.randf_range(-250.0, 250.0)
	)

	var desired_position := global_position + random_offset

	var map := navigation_agent.get_navigation_map()

	var valid_position := NavigationServer2D.map_get_closest_point(
		map,
		desired_position
	)

	navigation_agent.target_position = valid_position

	wander_timer.start(
		rng.randf_range(2.0, 5.0)
	)
	
func _on_wander_timer_timeout() -> void:
	if state == State.WANDER:
		choose_wander_target()
		
func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player = body
	state = State.CHASE
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body != player:
		return

	player = null
	state = State.WANDER

	choose_wander_target()
	
func chase_player() -> void:
	if not player:
		state = State.WANDER
		choose_wander_target()
		return

	navigation_agent.target_position = player.global_position

	move_along_navigation()
	
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body != player:
		return

	state = State.ATTACK
	velocity = Vector2.ZERO

	attack_player()

	attack_timer.start()
	
func _on_attack_area_body_exited(body: Node2D) -> void:
	if body != player:
		return

	attack_timer.stop()

	if player:
		state = State.CHASE
	else:
		state = State.WANDER
		
func _on_attack_timer_timeout() -> void:
	attack_player()


func attack_player() -> void:
	if not player:
		return

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
		
