extends Control

@onready var fade_mask: TextureRect = $FadeMask
@onready var scroll_container: ScrollContainer = $FadeMask/ScrollContainer
@onready var levels_container: VBoxContainer = $FadeMask/ScrollContainer/VBoxContainer
@onready var back_button: Button = $Panel/ButtonBack

var total_levels := 50

var top_spacer: Control
var bottom_spacer: Control

var first_level_button: Button
var last_level_button: Button


func _ready():
	# Скрываем содержимое скролла до завершения расчётов.
	$FadeMask.modulate.a = 0.0
	
	if levels_container == null:
		print("ОШИБКА: levels_container не найден!")
		return

	# Создаём или находим верхний spacer.
	top_spacer = _get_or_create_spacer("TopSpacer")
	levels_container.move_child(top_spacer, 0)

	# Создаём кнопки уровней.
	for i in range(1, total_levels + 1):
		var btn := Button.new()

		btn.text = "Уровень " + str(i)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 0)
		btn.add_theme_font_size_override("font_size", 48)

		btn.pressed.connect(_on_level_button_pressed.bind(i))

		levels_container.add_child(btn)

		# Запоминаем первую и последнюю кнопку.
		if i == 1:
			first_level_button = btn

		if i == total_levels:
			last_level_button = btn

	# Создаём или находим нижний spacer.
	bottom_spacer = _get_or_create_spacer("BottomSpacer")

	# BottomSpacer всегда должен находиться после всех кнопок.
	levels_container.move_child(
		bottom_spacer,
		levels_container.get_child_count() - 1
	)

	# Ждём, пока Godot рассчитает реальные размеры
	# ScrollContainer и кнопок.
	await get_tree().process_frame
	await get_tree().process_frame

	_update_spacer_sizes()

	# Даём VBoxContainer применить новые размеры spacer-ов.
	await get_tree().process_frame

	# Выставляем скролл в начало.
	scroll_container.scroll_vertical = 0

	# Показываем уже полностью рассчитанный интерфейс.
	$FadeMask.modulate.a = 1.0

	# Если размер окна изменится, пересчитываем spacer-ы.
	scroll_container.resized.connect(_update_spacer_sizes)

	# Кнопка "Назад".
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	else:
		print("ОШИБКА: кнопка 'Назад' не найдена!")


func _get_or_create_spacer(spacer_name: String) -> Control:
	var spacer := levels_container.get_node_or_null(spacer_name) as Control

	if spacer == null:
		spacer = Control.new()
		spacer.name = spacer_name
		levels_container.add_child(spacer)

	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	return spacer


func _update_spacer_sizes():
	if (
		scroll_container == null
		or top_spacer == null
		or bottom_spacer == null
		or first_level_button == null
		or last_level_button == null
	):
		return

	var viewport_height := scroll_container.size.y

	# В VBoxContainer у тебя separation = 10.
	# Получаем его автоматически, чтобы не прописывать вручную.
	var separation := levels_container.get_theme_constant("separation")

	# ------------------------------------------------
	# ВЕРХ
	# ------------------------------------------------
	#
	# Хотим:
	#
	#           центр ScrollContainer
	#                   ↓
	#        ─────────────────────
	#              [Уровень 1]
	#
	# Учитываем половину высоты кнопки
	# и separation между spacer и кнопкой.

	var top_height := (
		viewport_height / 3
		- first_level_button.size.y / 3
		- separation
	)

	# ------------------------------------------------
	# НИЗ
	# ------------------------------------------------
	#
	# Аналогично оставляем место после последней кнопки,
	# чтобы "Уровень 50" можно было докрутить до центра.

	var bottom_height := (
		viewport_height / 1.5
		- last_level_button.size.y / 1.5
		- separation
	)

	top_spacer.custom_minimum_size.y = maxf(0.0, top_height)
	bottom_spacer.custom_minimum_size.y = maxf(0.0, bottom_height)


func _on_level_button_pressed(level_number):
	print("Выбран уровень: ", level_number)

	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
