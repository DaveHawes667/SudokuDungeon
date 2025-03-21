extends Node

const DATA_PATH = "res://data/"
const GAME_DATA_FILE = "game_data.json"

var _game_data: Dictionary = {}
var _loaded_data: Dictionary = {}

func _ready() -> void:
	_load_game_data()

func _load_game_data() -> void:
	var file = FileAccess.open(DATA_PATH + GAME_DATA_FILE, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		_game_data = JSON.parse_string(json_string)
		file.close()
		
		# Load all referenced JSON files
		for category in _game_data:
			for file_path in _game_data[category]:
				_load_json_file(category, file_path)

func _load_json_file(category: String, file_path: String) -> void:
	var file = FileAccess.open(DATA_PATH + file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var data = JSON.parse_string(json_string)
		file.close()
		
		if not _loaded_data.has(category):
			_loaded_data[category] = {}
		
		_loaded_data[category][data.id] = data

func get_episode(episode_id: String) -> Dictionary:
	return _loaded_data.episodes.get(episode_id, {})

func get_entity(entity_id: String) -> Dictionary:
	return _loaded_data.entities.get(entity_id, {})

func get_all_episodes() -> Dictionary:
	return _loaded_data.episodes

