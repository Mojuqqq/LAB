extends Control


@onready var currency_label: Label = $CurrencyLabel


@onready var speed_value: Label = (
	$UpgradesContainer/SpeedRow/ValueLabel
)

@onready var speed_button: Button = (
	$UpgradesContainer/SpeedRow/UpgradeButton
)


@onready var attack_value: Label = (
	$UpgradesContainer/AttackRow/ValueLabel
)

@onready var attack_button: Button = (
	$UpgradesContainer/AttackRow/UpgradeButton
)


@onready var torch_value: Label = (
	$UpgradesContainer/TorchRow/ValueLabel
)

@onready var torch_button: Button = (
	$UpgradesContainer/TorchRow/UpgradeButton
)


@onready var back_button: Button = $BackButton


func _ready() -> void:
	speed_button.pressed.connect(
		_on_speed_pressed
	)

	attack_button.pressed.connect(
		_on_attack_pressed
	)

	torch_button.pressed.connect(
		_on_torch_pressed
	)

	back_button.pressed.connect(
		_on_back_pressed
	)

	GameData.currency_changed.connect(
		_on_currency_changed
	)

	GameData.upgrades_changed.connect(
		update_ui
	)

	update_ui()


func update_ui() -> void:
	currency_label.text = (
		"Монеты: %d"
		% GameData.currency
	)

	update_speed()
	update_attack()
	update_torch()


func update_speed() -> void:
	speed_value.text = (
		"%d"
		% int(GameData.get_speed())
	)

	if GameData.speed_level >= GameData.MAX_SPEED_LEVEL:
		speed_button.text = "MAX"
		speed_button.disabled = true
	else:
		var cost := GameData.get_speed_cost()

		speed_button.text = (
			"+  %d"
			% cost
		)

		speed_button.disabled = (
			GameData.currency < cost
		)


func update_attack() -> void:
	attack_value.text = (
		"%d"
		% GameData.get_attack_damage()
	)

	if GameData.attack_level >= GameData.MAX_ATTACK_LEVEL:
		attack_button.text = "MAX"
		attack_button.disabled = true
	else:
		var cost := GameData.get_attack_cost()

		attack_button.text = (
			"+  %d"
			% cost
		)

		attack_button.disabled = (
			GameData.currency < cost
		)


func update_torch() -> void:
	torch_value.text = (
		"x%.2f"
		% GameData.get_torch_scale()
	)

	if GameData.torch_level >= GameData.MAX_TORCH_LEVEL:
		torch_button.text = "MAX"
		torch_button.disabled = true
	else:
		var cost := GameData.get_torch_cost()

		torch_button.text = (
			"+  %d"
			% cost
		)

		torch_button.disabled = (
			GameData.currency < cost
		)


func _on_speed_pressed() -> void:
	GameData.buy_speed_upgrade()


func _on_attack_pressed() -> void:
	GameData.buy_attack_upgrade()


func _on_torch_pressed() -> void:
	GameData.buy_torch_upgrade()


func _on_currency_changed(_value: int) -> void:
	update_ui()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/ui/level_select.tscn"
	)
