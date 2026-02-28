extends RefCounted
class_name SaveData

## Данные игрока (сериализуемые)

# Основная информация
var player_name: String = "Racer"
var level: int = 1
var experience: int = 0
var money: int = 10000

# Прогресс карьеры
var career_tier: int = 0
var career_race_index: int = 0

# Статистика
var total_races: int = 0
var total_wins: int = 0
var total_distance: float = 0.0

# Характеристики персонажа (1.0 = база, 2.0 = макс)
var reaction_stat: float = 1.0      # Скорость реакции на старте
var shift_speed_stat: float = 1.0   # Скорость переключения передач

# Гараж
var owned_cars: Array = []          # ID владельцев автомобилей
var current_car_id: String = ""     # Текущий автомобиль

# Инвентарь (запчасти)
var inventory: Dictionary = {}

# Настройки
var settings: PlayerSettings = PlayerSettings.new()

func _init():
	pass
