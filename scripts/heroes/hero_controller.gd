class_name HeroController extends EntityController

var _original_position: Vector2
var _tilemap: TileMap
var _path_points = []
var _line2d: Line2D
var _is_drawing = false
var _encounteredEntities = []
var path_color = Color(1, 1, 0, 0.5)  # Yellow with transparency
var move_time = 0.2

enum HeroState {RESERVE, PICKED_UP, PLACED, DRAWING_PATH, MOVING,FINISHED_MOVE,DEFEATED,ATTACKING}

var _hero_state = HeroState.RESERVE
var _hero_class = "knight"

@onready var _ray : RayCast2D = ScriptUtilities.find_child(self, "RayCast2D")

func _getWorldPosFromMapPos(mapPos : Vector2i ):
	var local_pos = _tilemap.map_to_local(mapPos)
	return _tilemap.to_global(local_pos)	

func _snapToTile(globalPos: Vector2):
	var local_pos = _tilemap.to_local(globalPos)
	var map_pos = _tilemap.local_to_map(local_pos)
	local_pos = _tilemap.map_to_local(map_pos)
	return _tilemap.to_global(local_pos)	

func _ready():
	super._ready()
	_tilemap = get_node("/root/grid_movement_sample/TileMap")
	_original_position = position

	_hero_class = _entity_data.get("class", "knight")

	# Create Line2D for path visualization
	_line2d = Line2D.new()
	_line2d.default_color = path_color
	_line2d.width = 1
	_tilemap.add_child(_line2d)

func IsUnderMouse():
	var mouse_pos = get_global_mouse_position()
	var collider_shape = _colliderShape.shape as RectangleShape2D
	var collider_rect = Rect2(
		global_position - collider_shape.size/2,
		collider_shape.size
	)

	return collider_rect.has_point(mouse_pos)

func _input(event):

	var leftClickDown = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var leftClickUp = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed
	var mouseMotion = event is InputEventMouseMotion

	match _hero_state:
		HeroState.RESERVE:
			if IsUnderMouse() and leftClickDown:
				_start_drag();				
		HeroState.PICKED_UP:
			if leftClickUp:
				_end_drag();
			elif mouseMotion:
				position = get_global_mouse_position()
		HeroState.PLACED:
			if IsUnderMouse() and leftClickDown:
				_start_drawing();
		HeroState.DRAWING_PATH:
			if leftClickUp:
				_end_drawing();	
			elif mouseMotion:
				_update_path()
	

func _start_drag():
	_original_position = position
	_hero_state = HeroState.PICKED_UP

func _end_drag():	
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
		var world_pos = _getWorldPosFromMapPos(map_pos)
		position = world_pos		
		_hero_state = HeroState.PLACED
	else:
		# Return to original position
		position = _original_position
		_hero_state = HeroState.RESERVE

func _start_drawing():
	_hero_state = HeroState.DRAWING_PATH
	_path_points.clear()
	_line2d.clear_points()
	# Add current position as first point
	var snappedPos = _snapToTile(global_position)
	_path_points.append(snappedPos)
	_line2d.add_point(snappedPos)

func _update_path():
	if _hero_state != HeroState.DRAWING_PATH:
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
	_hero_state = HeroState.MOVING
	# Follow each point in the path
	for i in range(1, _path_points.size()):
		var start_pos = _path_points[i-1]
		var end_pos = _path_points[i]
		var direction = (end_pos - start_pos).normalized()

		# Flip sprite based on movement direction
		if direction.x < 0:  # Moving left
			_sprite.flip_h = true
		elif direction.x > 0:  # Moving right
			_sprite.flip_h = false
		
		# Check if movement is valid
		_ray.target_position = end_pos-start_pos
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
			# Handle collision with enemy or object
			var collider = _ray.get_collider()
			# Get the parent node which would have the EnemyController script
			var collidedEntity = collider.get_parent()
			if collidedEntity is EnemyController:
				# Combat resolution
				var enemy = collidedEntity as EnemyController				
				match _hero_class:
					"knight":
						await _resolveKnightCombat(enemy)

				_encounteredEntities.append(enemy)		
			else:
				break
			
	
	_hero_state = HeroState.FINISHED_MOVE
	_path_points.clear()
	_line2d.clear_points()

func _lastEncounteredEntity():
	return _encounteredEntities.back()		

func _lastEncounteredEntityValue():
	var enemy = _lastEncounteredEntity()
	if enemy:
		return enemy.get_health()
	else:
		return 0

func _resolveKnightCombat(enemy: EnemyController):
	if enemy.get_health() == 5:
		await _defeated()
	else:
		var lastValue = _lastEncounteredEntityValue()
		var enemyValue = enemy.get_health()
		if lastValue == 0:
			await _defeat(enemy)
		elif abs(lastValue - enemyValue) > 5:
			await _defeat(enemy)
		else:
			await _defeated()
			

func _defeated():
	await super._defeated()
	_hero_state = HeroState.DEFEATED

func _defeat(enemy: EnemyController):
	_hero_state = HeroState.ATTACKING
	set_state("attack")
	await _sprite.animation_finished
	await enemy._defeated()
	_hero_state = HeroState.MOVING
	#_follow_path()

func _process(delta):
	# Example of state changes based on movement
	if _hero_state == HeroState.MOVING:
		set_state("walk")
	elif _hero_state not in [HeroState.DEFEATED,HeroState.ATTACKING]:
		set_state("idle") 

	
