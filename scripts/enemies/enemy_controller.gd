class_name EnemyController extends Node2D

@export var enemy_id: String
@export var animation_speed = 0.1
@export var move_speed = 100.0

var _sprite: AnimatedSprite2D
var _current_state = "idle"
var _enemy_data: Dictionary
var _animations: Dictionary
var _tile_size = 8  # Size of a tile in pixels

func _ready():
	_load_enemy_data()
	_setup_sprite()

func _load_enemy_data():
	_enemy_data = DataManager.get_enemy(enemy_id)
	if _enemy_data.is_empty():
		push_error("Failed to load enemy data for ID: " + enemy_id)
		return
	
	_animations = _enemy_data.get("animations", {})
	if _animations.is_empty():
		push_error("No animations found for enemy: " + enemy_id)

func _setup_sprite():
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = SpriteFrames.new()
	#_sprite.sprite_frames.animation_speed = animation_speed
	
	# Load all animations from the enemy data
	for state in _animations:
		var sprite_folder = _enemy_data.get("sprite_folder", "")
		var texture_path = "res://sprites/enemies/" + sprite_folder + "/" + _animations[state] + ".png"
		var texture = load(texture_path)
		if texture:			
			_sprite.sprite_frames.add_animation(state)
			var frame_width = 64
			var frame_height = 64
			# Calculate number of columns and rows (assumes the texture dimensions are multiples of the frame size)
			var columns = texture.get_width() / frame_width
			var rows = texture.get_height() / frame_height

			# Loop through the grid and create an AtlasTexture for each frame
			for y in range(rows):
				for x in range(columns):
					var region = Rect2(x * frame_width, y * frame_height, frame_width, frame_height)
					var atlas = AtlasTexture.new()
					atlas.atlas = texture
					atlas.region = region
					_sprite.sprite_frames.add_frame(state, atlas)
		else:
			push_error("Failed to load texture: " + texture_path)
	
	add_child(_sprite)
	
	# Scale the sprite to fit within a tile
	var scale_factor = _tile_size / 64.0  # 64 is the frame size
	_sprite.scale = Vector2(scale_factor, scale_factor)
	
	_sprite.play("idle")

func set_state(new_state: String):
	if new_state != _current_state and _animations.has(new_state):
		_current_state = new_state
		_sprite.play(new_state)

func _process(delta):
	# Example of state changes based on movement
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		set_state("walk_attack")
	else:
		set_state("idle")

# Getter methods for enemy properties
func get_health() -> int:
	return _enemy_data.get("health", 0)

func get_attack() -> int:
	return _enemy_data.get("attack", 0)

func get_defense() -> int:
	return _enemy_data.get("defense", 0)

func get_movement_range() -> int:
	return _enemy_data.get("movement_range", 0)

func get_abilities() -> Array:
	return _enemy_data.get("abilities", []) 
