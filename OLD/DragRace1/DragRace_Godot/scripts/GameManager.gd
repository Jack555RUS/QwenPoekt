extends Node
## Менеджер игры (Singleton/Autoload)
## Управляет состоянием игры, сценами, временем

signal state_changed(old_state: GameState, new_state: GameState)
signal minute_passed(minutes: float)

enum GameState {
	MENU_MAIN,
	PLAYING,
	RACING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU_MAIN
var is_game_initialized: bool = false
var game_time: float = 0.0
var auto_save_timer: float = 0.0
const AUTO_SAVE_INTERVAL: float = 300.0  # 5 минут

func _ready():
	# Автозагрузка при старте игры
	print("🔧 GameManager: Инициализация...")
	initialize_game()

func _process(delta: float):
	if not is_game_initialized:
		return
	
	# Обновление времени игры
	game_time += delta
	auto_save_timer += delta
	
	# Проверка автосохранения каждые 5 минут
	if auto_save_timer >= AUTO_SAVE_INTERVAL:
		auto_save_timer = 0.0
		_save_game()
	
	# Проверка паузы (Escape)
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func initialize_game():
	if is_game_initialized:
		return
	
	print("=== GAME MANAGER: Инициализация игры ===")
	
	# Загрузка настроек
	SettingsManager.load_settings()
	
	# Инициализация SaveManager
	SaveManager.initialize()
	
	is_game_initialized = true
	set_game_state(GameState.MENU_MAIN)
	
	print("✅ Игра инициализирована")

func set_game_state(new_state: GameState):
	var old_state = current_state
	current_state = new_state
	
	print("🔄 Состояние: %s → %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])
	
	match new_state:
		GameState.MENU_MAIN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.PLAYING:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.RACING:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		GameState.PAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.GAME_OVER:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	state_changed.emit(old_state, new_state)

func toggle_pause():
	if current_state == GameState.RACING or current_state == GameState.PLAYING:
		set_game_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		set_game_state(GameState.PLAYING)

func _save_game():
	print("💾 Автосохранение...")
	SaveManager.auto_save()

func start_new_game(player_name: String):
	print("🎮 Новая игра: %s" % player_name)
	
	var new_data = SaveData.new()
	new_data.player_name = player_name
	new_data.money = 10000
	new_data.experience = 0
	new_data.level = 1
	new_data.career_tier = 0
	new_data.career_race_index = 0
	new_data.total_races = 0
	new_data.total_wins = 0
	new_data.total_distance = 0.0
	new_data.reaction_stat = 1.0
	new_data.shift_speed_stat = 1.0
	new_data.owned_cars = []
	new_data.current_car_id = ""
	new_data.inventory = {}
	
	SaveManager.create_new_save(new_data)
	set_game_state(GameState.PLAYING)

func load_game(save_slot: int):
	print("📂 Загрузка из слота %d" % save_slot)
	
	if SaveManager.load_game(save_slot):
		set_game_state(GameState.PLAYING)

func return_to_main_menu():
	print("🔙 Возврат в главное меню")
	set_game_state(GameState.MENU_MAIN)

func exit_game():
	print("🚪 Выход из игры")
	get_tree().quit()
