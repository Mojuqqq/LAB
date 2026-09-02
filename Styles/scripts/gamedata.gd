extends Node


signal currency_changed(value: int)
signal upgrades_changed


# -------------------------
# ВАЛЮТА
# -------------------------

var currency: int = 0


# -------------------------
# УЛУЧШЕНИЯ
# -------------------------

var speed_level: int = 0
var attack_level: int = 0
var torch_level: int = 0


# Базовые характеристики.
const BASE_SPEED: float = 250.0
const BASE_ATTACK: int = 1
const BASE_TORCH_SCALE: float = 1.0


# Прибавка за один уровень.
const SPEED_PER_LEVEL: float = 25.0
const ATTACK_PER_LEVEL: int = 1
const TORCH_PER_LEVEL: float = 0.15


# Максимальный уровень каждого улучшения.
const MAX_SPEED_LEVEL: int = 10
const MAX_ATTACK_LEVEL: int = 10
const MAX_TORCH_LEVEL: int = 10


const SAVE_PATH := "user://player_progress.json"


func _ready() -> void:
	load_game()


# ====================================================
# ХАРАКТЕРИСТИКИ
# ====================================================

func get_speed() -> float:
	return BASE_SPEED + speed_level * SPEED_PER_LEVEL


func get_attack_damage() -> int:
	return BASE_ATTACK + attack_level * ATTACK_PER_LEVEL


func get_torch_scale() -> float:
	return BASE_TORCH_SCALE + torch_level * TORCH_PER_LEVEL


# ====================================================
# ЦЕНЫ
# ====================================================

func get_speed_cost() -> int:
	return get_upgrade_cost(speed_level)


func get_attack_cost() -> int:
	return get_upgrade_cost(attack_level)


func get_torch_cost() -> int:
	return get_upgrade_cost(torch_level)


func get_upgrade_cost(level: int) -> int:
	return 25 + level * 25


# ====================================================
# ПОКУПКА
# ====================================================

func buy_speed_upgrade() -> bool:
	if speed_level >= MAX_SPEED_LEVEL:
		return false

	var cost := get_speed_cost()

	if currency < cost:
		return false

	currency -= cost
	speed_level += 1

	upgrade_completed()

	return true


func buy_attack_upgrade() -> bool:
	if attack_level >= MAX_ATTACK_LEVEL:
		return false

	var cost := get_attack_cost()

	if currency < cost:
		return false

	currency -= cost
	attack_level += 1

	upgrade_completed()

	return true


func buy_torch_upgrade() -> bool:
	if torch_level >= MAX_TORCH_LEVEL:
		return false

	var cost := get_torch_cost()

	if currency < cost:
		return false

	currency -= cost
	torch_level += 1

	upgrade_completed()

	return true


func upgrade_completed() -> void:
	currency_changed.emit(currency)
	upgrades_changed.emit()

	save_game()


# ====================================================
# ВАЛЮТА
# ====================================================

func add_currency(amount: int) -> void:
	currency += amount

	currency_changed.emit(currency)

	save_game()


# ====================================================
# СОХРАНЕНИЕ
# ====================================================

func save_game() -> void:
	var data := {
		"currency": currency,
		"speed_level": speed_level,
		"attack_level": attack_level,
		"torch_level": torch_level
	}

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file:
		file.store_string(
			JSON.stringify(data)
		)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if not file:
		return

	var data = JSON.parse_string(
		file.get_as_text()
	)

	if typeof(data) != TYPE_DICTIONARY:
		return

	currency = data.get(
		"currency",
		0
	)

	speed_level = data.get(
		"speed_level",
		0
	)

	attack_level = data.get(
		"attack_level",
		0
	)

	torch_level = data.get(
		"torch_level",
		0
	)
