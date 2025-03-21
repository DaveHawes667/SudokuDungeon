class_name EntryPointIndicator extends Node2D

@export var tilemap: TileMap
@export var episode_id: String = "episode1"
@export var indicator_color: Color = Color(0, 1, 0, 0.3)  # Semi-transparent green

var _indicators: Array[ColorRect] = []

func _ready():
	_show_entry_points()

func _show_entry_points():
	var episode_data = DataManager.get_episode(episode_id)
	if episode_data.is_empty():
		push_error("Failed to load episode data for: " + episode_id)
		return
		
	var entry_points = episode_data.get("entry_points", [])
	if entry_points.is_empty():
		push_error("No entry points found in episode: " + episode_id)
		return
		
	for entry in entry_points:
		var indicator = ColorRect.new()
		indicator.color = indicator_color
		indicator.size = Vector2(8, 8)  # Match tile size
		add_child(indicator)
		
		# Convert grid position to world position
		var map_pos = Vector2i(entry[0], entry[1])
		var local_position = tilemap.map_to_local(map_pos)
		local_position.x -= indicator.size.x/2;
		local_position.y -= indicator.size.y/2;
		var world_position = tilemap.to_global(local_position)
		indicator.position = world_position
		
		_indicators.append(indicator) 
