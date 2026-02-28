extends Node2D
## Контроллер сцены гонки

func _ready():
	print("🏁 Race Scene: Загружена")
	print("📍 Дистанция: 402м (1/4 мили)")
	print("⌨️ Нажмите ESC для возврата в меню")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("🔙 Возврат в главное меню")
			GameManager.return_to_main_menu()
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
