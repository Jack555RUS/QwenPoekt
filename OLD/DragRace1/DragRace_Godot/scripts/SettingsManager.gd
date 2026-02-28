extends Node
## Менеджер настроек игры (Singleton)

var current_settings: PlayerSettings = null
const SETTINGS_FILE: String = "user://settings.dat"

func _ready():
	pass

func load_settings():
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		if file:
			current_settings = file.get_var()
			file.close()
			print("✅ Настройки загружены")
	else:
		current_settings = PlayerSettings.new()
		print("📝 Созданы новые настройки")
	
	apply_settings()

func save_settings():
	if current_settings == null:
		return
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		file.store_var(current_settings)
		file.close()
		print("💾 Настройки сохранены")

func apply_settings():
	if current_settings == null:
		return
	
	# Разрешение
	var window_size = DisplayServer.window_get_size()
	if current_settings.resolution_index == 0:
		DisplayServer.window_set_size(Vector2i(1920, 1080))
	elif current_settings.resolution_index == 1:
		DisplayServer.window_set_size(Vector2i(1280, 720))
	elif current_settings.resolution_index == 2:
		DisplayServer.window_set_size(Vector2i(1600, 900))
	
	# Полноэкранный режим
	if current_settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Громкость
	AudioServer.set_bus_volume_db(0, linear_to_db(current_settings.master_volume / 100.0))
	
	print("⚙️ Настройки применены")

func set_resolution(index: int):
	current_settings.resolution_index = index
	apply_settings()

func set_fullscreen(fullscreen: bool):
	current_settings.fullscreen = fullscreen
	apply_settings()

func set_master_volume(volume: int):
	current_settings.master_volume = clamp(volume, 0, 100)
	AudioServer.set_bus_volume_db(0, linear_to_db(current_settings.master_volume / 100.0))

func get_available_resolutions() -> Array:
	# Возвращаем доступные разрешения
	return [
		Vector2i(1920, 1080),
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1366, 768),
		Vector2i(1280, 1024)
	]

func is_key_duplicate(new_key: String, exclude_action: String = "") -> bool:
	for action in current_settings.key_bindings:
		if action != exclude_action and current_settings.key_bindings[action] == new_key:
			return true
	return false

func rebind_key(action: String, new_key: String) -> bool:
	if is_key_duplicate(new_key, action):
		print("⚠️ Клавиша %s уже используется!" % new_key)
		return false
	
	current_settings.key_bindings[action] = new_key
	save_settings()
	print("✅ %s переназначена на %s" % [action, new_key])
	return true
