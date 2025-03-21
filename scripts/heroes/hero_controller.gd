class_name HeroController extends EntityController

var _is_dragging = false
var _is_placed = false
var _original_position: Vector2
var _tilemap: TileMap

func _snapToTile(globalPos: Vector2):
	var local_pos = _tilemap.to_local(globalPos)
	var map_pos = _tilemap.local_to_map(local_pos)
	local_pos = _tilemap.map_to_local(map_pos)
	return _tilemap.to_global(local_pos)	

func _ready():
	super._ready()
	_tilemap = get_node("/root/grid_movement_sample/TileMap")
	_original_position = position

func _input(event):
	if _is_placed:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Get mouse position and check if it's over the hero sprite
				var mouse_pos = get_global_mouse_position()
				var sprite_rect = Rect2(_sprite.global_position - (_sprite.scale * Vector2(_tile_size/2.0, _tile_size/2.0)), 
									  _sprite.scale * Vector2(_tile_size, _tile_size))
				
				if not sprite_rect.has_point(mouse_pos):
					return
				_start_drag()
			else:
				_end_drag()
	elif event is InputEventMouseMotion and _is_dragging:
		position = get_global_mouse_position()

func _start_drag():
	if not _is_placed:
		_is_dragging = true

func _end_drag():
	if not _is_dragging:
		return
		
	_is_dragging = false
	
	# Convert mouse position to grid position
	var mouse_pos = get_global_mouse_position()
	var local_pos = _tilemap.to_local(mouse_pos)
	var map_pos = _tilemap.local_to_map(local_pos)
	
	# Check if dropped on a valid entry point
	var episode_data = DataManager.get_episode("episode1")
	var entry_points = episode_data.get("entry_points", [])
	
	var is_valid_entry = false
	for entry in entry_points:
		if entry[0] == map_pos.x and entry[1] == map_pos.y:
			is_valid_entry = true
			break
	
	if is_valid_entry:
		# Snap to grid position
		var world_pos = _snapToTile(map_pos)
		position = world_pos
		_is_placed = true
	else:
		# Return to original position
		position = _original_position

func _process(delta):
	# Example of state changes based on movement
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		set_state("walk")
	else:
		set_state("idle") 
