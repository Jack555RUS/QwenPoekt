extends Button

@onready var start_button = $StartButton

# Сигнал для перехода в главное меню
signal start_pressed

func _ready():
	# Подключаемся к сигналу кнопки
	start_button.pressed.connect(_on_start_button_pressed)
	print("✅ Start Scene: Кнопка START готова")

func _on_start_button_pressed():
	print("🎮 КНОПКА START НАЖАТА!")
	print("🔄 Переход в главное меню...")
	emit_signal("start_pressed")
	# Переход в главное меню
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
