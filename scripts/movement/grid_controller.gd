class_name GridController extends Area2D

@export var tilemap : TileMap
@export var move_time = 0.2
@export var path_color = Color(1, 1, 0, 0.5)  # Yellow with transparency

@onready var _ray : RayCast2D = ScriptUtilities.find_child(self, "RayCast2D")
@onready var _tile_size = tilemap.tile_set.tile_size.x

var _is_moving = false
var _path_points = []
var _line2d: Line2D
var _is_drawing = false



func _snapToTile(globalPos: Vector2):
	var local_pos = tilemap.to_local(globalPos)
	var map_pos = tilemap.local_to_map(local_pos)
	local_pos = tilemap.map_to_local(map_pos)
	return tilemap.to_global(local_pos)	

func _ready():	
	# Create Line2D for path visualization
	_line2d = Line2D.new()
	_line2d.default_color = path_color
	_line2d.width = 1
	tilemap.add_child(_line2d)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drawing()
			else:
				_end_drawing()
	elif event is InputEventMouseMotion and _is_drawing:
		_update_path(event.position)

func _start_drawing():
	_is_drawing = true
	_path_points.clear()
	_line2d.clear_points()
	# Add current position as first point
	var snappedPos = _snapToTile(global_position)
	_path_points.append(snappedPos)
	_line2d.add_point(snappedPos)

func _update_path(mouse_pos: Vector2):
	if not _is_drawing:
		return
	
	var mouse_pos_ws = get_global_mouse_position()
	# Convert mouse position to tile coordinates	
	var tile_pos = _snapToTile(mouse_pos_ws)
	
	# Only add new point if it's on a different tile
	if _path_points.size() == 0 or _path_points[-1].distance_to(tile_pos) > _tile_size*0.5:
		_path_points.append(tile_pos)
		_line2d.add_point(tile_pos)

func _end_drawing():
	_is_drawing = false
	if _path_points.size() > 1:
		_follow_path()

func _follow_path():
	if _is_moving:
		return
		
	_is_moving = true
	
	# Follow each point in the path
	for i in range(1, _path_points.size()):
		var start_pos = _path_points[i-1]
		var end_pos = _path_points[i]
		var direction = (end_pos - start_pos).normalized()
		
		# Check if movement is valid
		_ray.target_position = direction * _tile_size
		_ray.force_raycast_update()
		
		if !_ray.is_colliding():
			var tween = create_tween()
			tween.tween_property(
				self, "position",
				end_pos,
				move_time
			).set_trans(Tween.TRANS_LINEAR)
			await tween.finished
		else:
			# Stop if we hit something
			break
	
	_is_moving = false
	_path_points.clear()
	_line2d.clear_points()

func _get_configuration_warnings():
	var warnings : PackedStringArray = []
	
	if not ScriptUtilities.find_child(self, "Raycast2D"):
		warnings.append("Node does not have a Raycast2D")
	
	return warnings
