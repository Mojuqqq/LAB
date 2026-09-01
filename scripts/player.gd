extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)

@export var speed: float = 250.0
@export var idle_delay: float = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var max_health: int = 5


var health: int
var idle_timer: float = 0.0


func _ready() -> void:
	health = max_health

	animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	if direction != Vector2.ZERO:
		idle_timer = 0.0

		# Персонаж изначально нарисован лицом вверх.
		rotation = direction.angle() + PI / 2

		# Не перезапускаем walk, если она уже идёт.
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")

	else:
		idle_timer += delta

		# Не переключаемся в idle мгновенно.
		# Это позволяет короткому нажатию показать сам шаг.
		if idle_timer >= idle_delay:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

	move_and_slide()
	
func take_damage(damage: int) -> void:
	health = maxi(health - damage, 0)

	health_changed.emit(
		health,
		max_health
	)

	print("Игрок получил урон: ", damage)
	print("HP: ", health, "/", max_health)

	if health <= 0:
		die()


func die() -> void:
	print("Игрок погиб!")
