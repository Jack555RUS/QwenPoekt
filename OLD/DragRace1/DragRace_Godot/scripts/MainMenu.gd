extends Node2D
## Контроллер главного меню

var new_game_button: Button
var continue_button: Button
var settings_button: Button
var exit_button: Button

func _ready():
	# Ищем кнопки в сцене
	new_game_button = find_child("NewGameButton", true, false) as Button
	continue_button = find_child("ContinueButton", true, false) as Button
	settings_button = find_child("SettingsButton", true, false) as Button
	exit_button = find_child("ExitButton", true, false) as Button
	
	# Проверяем что кнопки найдены
	if not new_game_button or not continue_button or not settings_button or not exit_button:
		push_error("❌ Кнопки не найдены в сцене MainMenu!")
		return
	
	# Подключаемся к кнопкам
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	print("✅ MainMenu: Главное меню загружено")
	
	# Проверяем есть ли сохранения
	var has_saves = false
	for i in range(SaveManager.MANUAL_SAVE_SLOTS):
		if SaveManager.has_save(i):
			has_saves = true
			break
	
	continue_button.disabled = not has_saves
	if has_saves:
		print("📂 Найдены сохранения - кнопка Continue активна")
	else:
		print("📂 Сохранений нет - кнопка Continue отключена")

func _on_new_game_pressed():
	print("🎮 NEW GAME нажата")
	GameManager.start_new_game("Racer")
	get_tree().change_scene_to_file("res://scenes/Race.tscn")

func _on_continue_pressed():
	print("▶️ CONTINUE нажата")
	# Ищем последнее сохранение
	for i in range(SaveManager.MANUAL_SAVE_SLOTS - 1, -1, -1):
		if SaveManager.has_save(i):
			GameManager.load_game(i)
			get_tree().change_scene_to_file("res://scenes/Race.tscn")
			return

func _on_settings_pressed():
	print("⚙️ SETTINGS нажата")
	# TODO: Открыть панель настроек

func _on_exit_pressed():
	print("🚪 EXIT нажата")
	GameManager.exit_game()
