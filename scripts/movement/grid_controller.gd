class_name GridController extends Area2D

@export var tilemap : TileMapLayer
@export var episode_id: String = "episode1"  # Default to first episode


var _episode_data: Dictionary

func _ready():	
	# Load episode data
	_episode_data = DataManager.get_episode(episode_id)
	if _episode_data.is_empty():
		push_error("Failed to load episode data for: " + episode_id)
		return	

	

func _snapToTile(globalPos: Vector2):
	var local_pos = tilemap.to_local(globalPos)
	var map_pos = tilemap.local_to_map(local_pos)
	local_pos = tilemap.map_to_local(map_pos)
	return tilemap.to_global(local_pos)	




func _get_configuration_warnings():
	var warnings : PackedStringArray = []
	
	if not ScriptUtilities.find_child(self, "Raycast2D"):
		warnings.append("Node does not have a Raycast2D")
	
	return warnings
