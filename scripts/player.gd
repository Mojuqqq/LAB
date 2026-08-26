extends CharacterBody2D


@export var speed: float = 250.0
@export var idle_delay: float = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var idle_timer: float = 0.0


func _ready() -> void:
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
