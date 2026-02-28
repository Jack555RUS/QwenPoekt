extends RefCounted
class_name SaveFileData

## Данные для сохранения в файл

var player_data: SaveData
var save_date: String
var save_time: String
var is_auto_save: bool

func _init(data: SaveData = null, auto: bool = false):
	if data:
		player_data = data
	else:
		player_data = SaveData.new()
	
	is_auto_save = auto
	
	var datetime = Time.get_datetime_dict_from_system()
	save_date = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]
	save_time = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
