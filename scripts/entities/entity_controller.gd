class_name EntityController extends Node2D

@export var entity_id: String

var _sprite: AnimatedSprite2D
var _current_state = "idle"
var _entity_data: Dictionary
var _animations: Dictionary
var _tile_size = 32  # Size of a tile in pixels
var _colliderShape: CollisionShape2D
var _sprite_scale_factor : float = 1.0

func _ready():
	_load_entity_data()
	_setup_sprite()
	_setup_collider()
	# Add self to camera targeter's list of targets	
	var camera_targeter = get_node("/root/grid_movement_sample/Camera2D/CameraTargeter")
	if camera_targeter:
		camera_targeter.add_target(self)
	else:
		push_error("Could not find CameraTargeter node")

func _load_entity_data():
	_entity_data = DataManager.get_entity(entity_id)
	if _entity_data.is_empty():
		push_error("Failed to load entity data for ID: " + entity_id)
		return
	
	_animations = _entity_data.get("animations", {})
	if _animations.is_empty():
		push_error("No animations found for entity: " + entity_id)

func _setup_sprite():
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = SpriteFrames.new()
	#_sprite.sprite_frames.animation_speed = animation_speed
	var widest_frame = 0.0
	var tallest_frame = 0.0
	# Load all animations from the enemy data
	for state in _animations:
		var sprite_folder = _entity_data.get("sprite_folder", "")
		# Get all textures in the sprite folder		
		var animation_name = _animations[state].get("name", "")
		var dir = DirAccess.open("res://sprites/" + sprite_folder + "/" + animation_name)		
		var textures = []
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".png"):
					textures.append(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
		_sprite.sprite_frames.add_animation(state)
		_sprite.sprite_frames.set_animation_loop(state, _animations[state].get("loop", true))
		
		# Sort textures by frame number (last 3 digits)
		textures.sort_custom(func(a, b):
			var a_num = a.substr(len(a)-7, 3).to_int() # Get ###.png
			var b_num = b.substr(len(b)-7, 3).to_int()
			return a_num < b_num
		)
		
		for textureFileName in textures:
			var texture = load("res://sprites/" + sprite_folder + "/" + animation_name + "/" + textureFileName);
			if texture:
				widest_frame = max(widest_frame, texture.get_width())
				tallest_frame = max(tallest_frame, texture.get_height())
				_sprite.sprite_frames.add_frame(state, texture)
			else:
				push_error("Failed to load texture: " + textureFileName)
	
	add_child(_sprite)
	
	# Scale the sprite to fit within a tile	
	_sprite_scale_factor = _tile_size/float(max(widest_frame, tallest_frame))
	_sprite.scale = Vector2(_sprite_scale_factor, _sprite_scale_factor)
	
	_sprite.play("idle")

func _setup_collider():
	# Create a collision shape	
	_colliderShape = ScriptUtilities.find_child(self, "CollisionShape2D");
	
	# Calculate the largest frame size across all animations
	var largest_width = 0
	var largest_height = 0
	
	for state in _animations:
		var frame_count = _sprite.sprite_frames.get_frame_count(state)
		for i in range(frame_count):
			var frame = _sprite.sprite_frames.get_frame_texture(state, i)
			if frame:
				largest_width = max(largest_width, frame.get_width())
				largest_height = max(largest_height, frame.get_height())
	
	# Create a rectangle shape based on the largest frame size
	var shape = RectangleShape2D.new()
	var scale_factor = _sprite_scale_factor
	shape.size = Vector2(largest_width * scale_factor, largest_height * scale_factor)
	_colliderShape.shape = shape
	#_colliderObject.set_collision_mask_value(1, true)

func set_state(new_state: String):
	if new_state != _current_state and _animations.has(new_state):
		_current_state = new_state		
		_sprite.play(new_state)

func _defeated(defeatedBy : EntityController):
	if defeatedBy:
		defeatedBy.set_state("attack")
		set_state("hurt");
		await defeatedBy._sprite.animation_finished
		defeatedBy.set_state("idle")
	set_state("death")
	await _sprite.animation_finished
	_sprite.visible = false
	_colliderShape.disabled = true

# Getter methods for entity properties
func get_health() -> int:
	return _entity_data.get("health", 0)
