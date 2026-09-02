extends PointLight2D


@export var base_energy: float = 1.1
@export var energy_flicker: float = 0.12

@export var base_scale: float = 0.8
@export var scale_flicker: float = 0.025

@export var flicker_speed: float = 8.0


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0

	var flicker := (
		sin(time * flicker_speed)
		+ sin(time * flicker_speed * 1.7) * 0.5
		+ sin(time * flicker_speed * 2.3) * 0.25
	)

	energy = base_energy + flicker * energy_flicker
	texture_scale = base_scale + flicker * scale_flicker
