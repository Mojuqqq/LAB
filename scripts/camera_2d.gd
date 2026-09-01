extends Camera2D


@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.5

@export var mouse_zoom_step: float = 0.1
@export var zoom_smooth_speed: float = 10.0
@export var pinch_sensitivity: float = 1.0


var target_zoom: float = 1.0

var touches: Dictionary = {}
var last_pinch_distance: float = 0.0


func _ready() -> void:
	target_zoom = zoom.x


func _process(delta: float) -> void:
	var current_zoom := zoom.x

	current_zoom = lerpf(
		current_zoom,
		target_zoom,
		1.0 - exp(-zoom_smooth_speed * delta)
	)

	zoom = Vector2.ONE * current_zoom


func _unhandled_input(event: InputEvent) -> void:
	# -------------------------
	# КОЛЕСО МЫШИ
	# -------------------------

	if event is InputEventMouseButton:
		if not event.pressed:
			return

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(mouse_zoom_step)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(-mouse_zoom_step)


	# -------------------------
	# КАСАНИЯ НА ТЕЛЕФОНЕ
	# -------------------------

	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

		if touches.size() != 2:
			last_pinch_distance = 0.0


	elif event is InputEventScreenDrag:
		touches[event.index] = event.position

		if touches.size() == 2:
			handle_pinch()


func change_zoom(amount: float) -> void:
	target_zoom = clampf(
		target_zoom + amount,
		min_zoom,
		max_zoom
	)


func handle_pinch() -> void:
	var positions := touches.values()

	var first_touch: Vector2 = positions[0]
	var second_touch: Vector2 = positions[1]

	var current_distance := first_touch.distance_to(
		second_touch
	)

	if last_pinch_distance > 0.0:
		var ratio := (
			current_distance
			/ last_pinch_distance
		)

		target_zoom *= pow(
			ratio,
			pinch_sensitivity
		)

		target_zoom = clampf(
			target_zoom,
			min_zoom,
			max_zoom
		)

	last_pinch_distance = current_distance
