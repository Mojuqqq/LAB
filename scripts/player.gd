extends CharacterBody2D


signal health_changed(
	current_health: int,
	max_health: int
)


@export var speed: float = 250.0
@export var idle_delay: float = 0.0

@export var max_health: int = 5

@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.4


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var attack_area: Area2D = (
	$AttackOrigin/AttackArea
)


var health: int
var idle_timer: float = 0.0

var can_attack: bool = true


func _ready() -> void:
	health = max_health

	animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	handle_movement(delta)

	if Input.is_action_just_pressed("attack"):
		attack()


func handle_movement(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	if direction != Vector2.ZERO:
		idle_timer = 0.0

		# Персонаж нарисован лицом вверх.
		rotation = direction.angle() + PI / 2.0

		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")

	else:
		idle_timer += delta

		if idle_timer >= idle_delay:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

	move_and_slide()


func attack() -> void:
	if not can_attack:
		return

	can_attack = false

	var bodies := attack_area.get_overlapping_bodies()

	for body in bodies:
		if body == self:
			continue

		if body.has_method("take_damage"):
			body.take_damage(
				attack_damage
			)

	await get_tree().create_timer(
		attack_cooldown
	).timeout

	can_attack = true


func take_damage(damage: int) -> void:
	health = maxi(
		health - damage,
		0
	)

	health_changed.emit(
		health,
		max_health
	)

	print(
		"Игрок получил урон: ",
		damage
	)

	print(
		"HP: ",
		health,
		"/",
		max_health
	)

	if health <= 0:
		die()


func die() -> void:
	print("Игрок погиб!")
