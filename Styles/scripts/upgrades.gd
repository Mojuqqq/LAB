extends Control


@onready var currency_label: Label = $CurrencyLabel


@onready var speed_value: Label = (
	$VBoxContainer/UpgradesContainer/SpeedRow/ValueLabel
)

@onready var speed_button: Button = (
	$VBoxContainer/UpgradesContainer/SpeedRow/UpgradeButton
)


@onready var attack_value: Label = (
	$VBoxContainer/UpgradesContainer/AttackRow/ValueLabel
)

@onready var attack_button: Button = (
	$VBoxContainer/UpgradesContainer/AttackRow/UpgradeButton
)


@onready var torch_value: Label = (
	$VBoxContainer/UpgradesContainer/TorchRow/ValueLabel
)

@onready var torch_button: Button = (
	$VBoxContainer/UpgradesContainer/TorchRow/UpgradeButton
)


# Кнопка "Назад".
@onready var back_button: Button = (
	$VBoxContainer/UpgradesContainer/predumatname/menu
)

# Кнопка "Продолжить".
@onready var continue_button: Button = (
	$VBoxContainer/UpgradesContainer/predumatname/levelselect
)


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

	continue_button.pressed.connect(
		_on_continue_pressed
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


# ====================================================
# СКОРОСТЬ
# ====================================================

func update_speed() -> void:
	var current_speed := GameData.get_speed()

	speed_value.text = (
		"%d"
		% int(current_speed)
	)

	if GameData.speed_level >= GameData.MAX_SPEED_LEVEL:
		speed_button.text = "MAX"
		speed_button.disabled = true

	else:
		var cost := GameData.get_speed_cost()

		speed_button.text = (
			"+ %d"
			% cost
		)

		speed_button.disabled = (
			GameData.currency < cost
		)


func _on_speed_pressed() -> void:
	GameData.buy_speed_upgrade()


# ====================================================
# АТАКА
# ====================================================

func update_attack() -> void:
	var current_attack := GameData.get_attack_damage()

	attack_value.text = (
		"%d"
		% current_attack
	)

	if GameData.attack_level >= GameData.MAX_ATTACK_LEVEL:
		attack_button.text = "MAX"
		attack_button.disabled = true

	else:
		var cost := GameData.get_attack_cost()

		attack_button.text = (
			"+ %d"
			% cost
		)

		attack_button.disabled = (
			GameData.currency < cost
		)


func _on_attack_pressed() -> void:
	GameData.buy_attack_upgrade()


# ====================================================
# ФАКЕЛ
# ====================================================

func update_torch() -> void:
	var current_torch := GameData.get_torch_scale()

	torch_value.text = (
		"x%.2f"
		% current_torch
	)

	if GameData.torch_level >= GameData.MAX_TORCH_LEVEL:
		torch_button.text = "MAX"
		torch_button.disabled = true

	else:
		var cost := GameData.get_torch_cost()

		torch_button.text = (
			"+ %d"
			% cost
		)

		torch_button.disabled = (
			GameData.currency < cost
		)


func _on_torch_pressed() -> void:
	GameData.buy_torch_upgrade()


# ====================================================
# ВАЛЮТА
# ====================================================

func _on_currency_changed(_value: int) -> void:
	update_ui()


# ====================================================
# НАВИГАЦИЯ
# ====================================================

func _on_back_pressed() -> void:
	# Возвращаемся в главное меню.
	get_tree().change_scene_to_file(
		"res://scenes/ui/menu.tscn"
	)


func _on_continue_pressed() -> void:
	# Переходим к выбору уровня.
	get_tree().change_scene_to_file(
		"res://scenes/ui/level_select.tscn"
	)
