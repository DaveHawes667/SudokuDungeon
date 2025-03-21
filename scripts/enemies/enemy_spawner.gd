class_name EnemySpawner extends Node2D

@export var episode_id: String = "episode1"
@export var tilemap: TileMap

var _enemy_scene = preload("res://scenes/enemy.tscn")
var _tile_size = 8  # Size of a tile in pixels

func _ready():
	_spawn_enemies()

func _spawn_enemies():
	var episode_data = DataManager.get_episode(episode_id)
	if episode_data.is_empty():
		push_error("Failed to load episode data for: " + episode_id)
		return
	
	var enemies = episode_data.get("enemies", [])
	for enemy_data in enemies:
		var enemy_id = enemy_data.get("id")
		var position = enemy_data.get("position")
		
		if enemy_id and position:
			_spawn_enemy(enemy_id, position)
		else:
			push_error("Invalid enemy data in episode: " + episode_id)

func _spawn_enemy(enemy_id: String, grid_position: Array):
	
	var enemy = _enemy_scene.instantiate()
	enemy.enemy_id = enemy_id
	add_child(enemy)
	
	# Set the enemy ID to load its data
	enemy.enemy_id = enemy_id
	
	# Convert grid position to world position
	var map_pos = Vector2i(grid_position[0], grid_position[1])
	var local_position = tilemap.map_to_local(map_pos)
	var world_position = tilemap.to_global(local_position)
	enemy.position = world_position 
