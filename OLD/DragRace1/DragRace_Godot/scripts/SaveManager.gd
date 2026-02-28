extends Node
## Менеджер сохранений (Singleton/Autoload)
## 5 ручных слотов + 5 автосохранений

signal save_loaded
signal save_created

const MANUAL_SAVE_SLOTS: int = 5
const AUTO_SAVE_SLOTS: int = 5
const SAVE_FOLDER: String = "user://saves/"
const MANUAL_PREFIX: String = "save_"
const AUTO_PREFIX: String = "autosave_"

var current_data: SaveData = null
var current_auto_save_index: int = 0
var is_initialized: bool = false

func _ready():
	pass

func initialize():
	if is_initialized:
		return
	
	# Создание папки для сохранений
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_FOLDER):
		dir.make_dir(SAVE_FOLDER)
	
	# Загрузка индекса автосохранения
	load_auto_save_index()
	
	is_initialized = true
	print("✅ SaveManager инициализирован")

func get_save_path(slot: int, is_auto_save: bool = false) -> String:
	var prefix = AUTO_PREFIX if is_auto_save else MANUAL_PREFIX
	return SAVE_FOLDER + prefix + str(slot) + ".data"

func create_new_save(data: SaveData):
	current_data = data
	save_game(0)
	print("✅ Новая игра создана: %s" % data.player_name)

func save_game(slot: int):
	if current_data == null:
		print("❌ Нет данных для сохранения!")
		return
	
	if slot < 0 or slot >= MANUAL_SAVE_SLOTS:
		print("❌ Неверный слот сохранения: %d" % slot)
		return
	
	var save_data = SaveFileData.new(current_data, false)
	var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Игра сохранена в слот %d" % slot)

func load_game(slot: int) -> bool:
	var path = get_save_path(slot)
	
	if not FileAccess.file_exists(path):
		print("⚠️ Слот %d пуст" % slot)
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var save_data: SaveFileData = file.get_var()
		file.close()
		
		current_data = save_data.player_data
		
		print("📂 Игра загружена из слота %d" % slot)
		print("   Игрок: %s" % current_data.player_name)
		print("   Деньги: $%d" % current_data.money)
		print("   Уровень: %d" % current_data.level)
		
		save_loaded.emit()
		return true
	
	return false

func auto_save():
	if current_data == null:
		print("⚠️ Нечего автосохранять")
		return
	
	var save_data = SaveFileData.new(current_data, true)
	var path = get_save_path(current_auto_save_index, true)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Автосохранение #%d" % (current_auto_save_index + 1))
	
	# Циклический переход к следующему слоту
	current_auto_save_index = (current_auto_save_index + 1) % AUTO_SAVE_SLOTS
	save_auto_save_index()

func load_auto_save(index: int) -> bool:
	if index < 0 or index >= AUTO_SAVE_SLOTS:
		print("❌ Неверный индекс автосохранения: %d" % index)
		return false
	
	var path = get_save_path(index, true)
	
	if not FileAccess.file_exists(path):
		print("⚠️ Автосохранение #%d не найдено" % (index + 1))
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var save_data: SaveFileData = file.get_var()
		file.close()
		
		current_data = save_data.player_data
		
		print("📂 Автосохранение #%d загружено" % (index + 1))
		print("   Дата: %s %s" % [save_data.save_date, save_data.save_time])
		
		save_loaded.emit()
		return true
	
	return false

func has_save(slot: int, is_auto_save: bool = false) -> bool:
	var path = get_save_path(slot, is_auto_save)
	return FileAccess.file_exists(path)

func get_save_info(slot: int, is_auto_save: bool = false) -> SaveInfo:
	var path = get_save_path(slot, is_auto_save)
	
	if not FileAccess.file_exists(path):
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var save_data: SaveFileData = file.get_var()
		file.close()
		
		var info = SaveInfo.new()
		info.player_name = save_data.player_data.player_name
		info.date = save_data.save_date
		info.time = save_data.save_time
		info.level = save_data.player_data.level
		info.money = save_data.player_data.money
		info.is_auto_save = save_data.is_auto_save
		
		return info
	
	return null

func delete_save(slot: int, is_auto_save: bool = false):
	var path = get_save_path(slot, is_auto_save)
	
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("🗑️ Сохранение удалено: слот %d" % slot)

func save_auto_save_index():
	var file = FileAccess.open("user://autosave_index.dat", FileAccess.WRITE)
	if file:
		file.store_var(current_auto_save_index)
		file.close()

func load_auto_save_index():
	var path = "user://autosave_index.dat"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			current_auto_save_index = file.get_var()
			file.close()
	else:
		current_auto_save_index = 0

func get_current_data() -> SaveData:
	return current_data

func save_all():
	if current_data != null:
		save_game(0)
	SettingsManager.save_settings()
