extends RefCounted
class_name PlayerSettings

## Настройки игрока

var resolution_index: int = 0
var fullscreen: bool = true
var master_volume: int = 80
var music_volume: int = 70
var engine_volume: int = 100
var sfx_volume: int = 100
var key_bindings: Dictionary = {
	"accelerate": "W",
	"shift_up": "D",
	"shift_down": "A",
	"nitro": "LeftShift",
	"pause": "Escape"
}

func _init():
	pass
