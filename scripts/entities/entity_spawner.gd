class_name EntitySpawner extends Node2D

@export var episode_id: String = "episode1"
@export var tilemap: TileMapLayer

var _enemy_scene = preload("res://scenes/enemy.tscn")
var _hero_scene = preload("res://scenes/hero.tscn")
var _object_scene = preload("res://scenes/object.tscn")

func _ready():
	_spawn_entities()

func _spawn_entities():
	var episode_data = DataManager.get_episode(episode_id)
	if episode_data.is_empty():
		push_error("Failed to load episode data for: " + episode_id)
		return
	
	var entities = episode_data.get("entities", [])
	for entity_data in entities:
		var entity_type = entity_data.get("type", "")
		var entity_id = entity_data.get("id")
		var start_pos = entity_data.get("position")
		
		if entity_id and start_pos:
			match entity_type:
				"enemy":
					_spawn_entity(_enemy_scene, entity_id, start_pos)
				"hero":
					_spawn_entity(_hero_scene, entity_id, start_pos)
				"object":
					_spawn_entity(_object_scene, entity_id, start_pos)
				_:
					push_error("Unknown entity type: " + entity_type)
		else:
			push_error("Invalid entity data in episode: " + episode_id)

func _spawn_entity(scene: PackedScene, entity_id: String, grid_position: Array):
	var entity = scene.instantiate()
	entity.entity_id = entity_id
	add_child(entity)
	
	# Convert grid position to world position
	var map_pos = Vector2i(grid_position[0], grid_position[1])
	var local_position = tilemap.map_to_local(map_pos)
	var world_position = tilemap.to_global(local_position)
	entity.position = world_position 
