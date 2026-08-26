extends CharacterBody2D


@export var speed: float = 250.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	if direction != Vector2.ZERO:
		animated_sprite.rotation = direction.angle() - PI / 2
		animated_sprite.play("walk")
	else:
		animated_sprite.stop()

	move_and_slide()
