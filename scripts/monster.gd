extends CharacterBody2D


enum State {
	WANDER,
	CHASE,
	ATTACK
}

@export var max_health: int = 3
@export var speed: float = 80.0
@export var rotation_speed: float = 10.0

@export var attack_damage: int = 1
@export var attack_interval: float = 1.0

# Не выбираем слишком близкие случайные цели.
@export var min_wander_distance: float = 100.0

# Если монстр всё-таки физически застрял,
# через это время он мгновенно выберет другой маршрут.
@export var stuck_check_interval: float = 0.4
@export var stuck_min_distance: float = 5.0


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_area: Area2D = $AttackArea
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer


var health: int
var state: State = State.WANDER
var player: Node2D = null

var rng := RandomNumberGenerator.new()

var stuck_timer: float = 0.0
var stuck_check_position: Vector2


func _ready() -> void:
	health = max_health
	rng.randomize()

	detection_area.body_entered.connect(
		_on_detection_area_body_entered
	)

	detection_area.body_exited.connect(
		_on_detection_area_body_exited
	)

	attack_area.body_entered.connect(
		_on_attack_area_body_entered
	)

	attack_area.body_exited.connect(
		_on_attack_area_body_exited
	)

	attack_timer.wait_time = attack_interval

	attack_timer.timeout.connect(
		_on_attack_timer_timeout
	)

	# Для тайлового лабиринта маршрут лучше вести
	# через центры переходов между тайлами.
	navigation_agent.path_postprocessing = (
		NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
	)

	# Монстру не нужно пытаться попасть точно в одну точку.
	navigation_agent.path_desired_distance = 8.0
	navigation_agent.target_desired_distance = 24.0

	navigation_agent.max_speed = speed
	navigation_agent.radius = 18.0

	stuck_check_position = global_position

	await wait_for_navigation()

	choose_wander_target()


func wait_for_navigation() -> void:
	var map := navigation_agent.get_navigation_map()

	while NavigationServer2D.map_get_iteration_id(map) == 0:
		await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	match state:
		State.WANDER:
			update_wander(delta)

		State.CHASE:
			update_chase(delta)

		State.ATTACK:
			velocity = Vector2.ZERO

	move_and_slide()

	update_stuck_detection(delta)


# ----------------------------------------------------
# WANDER
# ----------------------------------------------------

func update_wander(delta: float) -> void:
	# Дошёл до текущей точки —
	# сразу выбираем следующую.
	if navigation_agent.is_navigation_finished():
		choose_wander_target()
		return

	move_along_navigation(delta)


func choose_wander_target() -> void:
	if state != State.WANDER:
		return

	var map := navigation_agent.get_navigation_map()

	if NavigationServer2D.map_get_iteration_id(map) == 0:
		return

	var target := global_position

	# Несколько попыток найти точку,
	# которая не находится прямо рядом с монстром.
	for attempt in range(10):
		var candidate := NavigationServer2D.map_get_random_point(
			map,
			navigation_agent.navigation_layers,
			true
		)

		if global_position.distance_to(candidate) >= min_wander_distance:
			target = candidate
			break

		target = candidate

	navigation_agent.target_position = target


# ----------------------------------------------------
# MOVEMENT
# ----------------------------------------------------

func move_along_navigation(delta: float) -> void:
	var next_position := navigation_agent.get_next_path_position()

	var direction := global_position.direction_to(
		next_position
	)

	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		return

	velocity = direction * speed

	rotate_towards_direction(
		direction,
		delta
	)


func rotate_towards_direction(
	direction: Vector2,
	delta: float
) -> void:
	if direction == Vector2.ZERO:
		return

	# Исходная картинка монстра смотрит вверх.
	var target_rotation := (
		direction.angle()
		+ PI / 2.0
	)

	var rotation_weight := (
		1.0
		- exp(-rotation_speed * delta)
	)

	rotation = lerp_angle(
		rotation,
		target_rotation,
		rotation_weight
	)


# ----------------------------------------------------
# STUCK PROTECTION
# ----------------------------------------------------

func update_stuck_detection(delta: float) -> void:
	if state == State.ATTACK:
		stuck_timer = 0.0
		stuck_check_position = global_position
		return

	stuck_timer += delta

	if stuck_timer < stuck_check_interval:
		return

	var distance_moved := global_position.distance_to(
		stuck_check_position
	)

	# Если монстр хотел двигаться,
	# но практически не сдвинулся.
	if velocity.length() > 1.0:
		if distance_moved < stuck_min_distance:
			if state == State.WANDER:
				choose_wander_target()

			elif state == State.CHASE and player:
				navigation_agent.target_position = (
					player.global_position
				)

	stuck_check_position = global_position
	stuck_timer = 0.0


# ----------------------------------------------------
# PLAYER DETECTION
# ----------------------------------------------------

func _on_detection_area_body_entered(
	body: Node2D
) -> void:
	if not body.is_in_group("player"):
		return

	player = body
	state = State.CHASE


func _on_detection_area_body_exited(
	body: Node2D
) -> void:
	if body != player:
		return

	player = null
	state = State.WANDER

	choose_wander_target()


# ----------------------------------------------------
# CHASE
# ----------------------------------------------------

func update_chase(delta: float) -> void:
	if not player:
		state = State.WANDER
		choose_wander_target()
		return

	# Обновляем цель игрока.
	navigation_agent.target_position = (
		player.global_position
	)

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	move_along_navigation(delta)


# ----------------------------------------------------
# ATTACK
# ----------------------------------------------------

func _on_attack_area_body_entered(
	body: Node2D
) -> void:
	if body != player:
		return

	state = State.ATTACK
	velocity = Vector2.ZERO

	attack_player()

	attack_timer.start()


func _on_attack_area_body_exited(
	body: Node2D
) -> void:
	if body != player:
		return

	attack_timer.stop()

	if player:
		state = State.CHASE
	else:
		state = State.WANDER
		choose_wander_target()


func _on_attack_timer_timeout() -> void:
	attack_player()


func attack_player() -> void:
	if not player:
		return

	if player.has_method("take_damage"):
		player.take_damage(
			attack_damage
		)
	else:
		print("Монстр атакует игрока!")
		
func take_damage(damage: int) -> void:
	health = maxi(
		health - damage,
		0
	)

	print(
		"Монстр получил урон: ",
		damage
	)

	print(
		"Monster HP: ",
		health,
		"/",
		max_health
	)

	if health <= 0:
		die()


func die() -> void:
	queue_free()
