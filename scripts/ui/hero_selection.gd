class_name HeroSelection extends Node2D

@export var tilemap: TileMap
@export var hero_scene: PackedScene
@export var episode_id: String = "episode1"

var _hero_spacing = 64  # Space between heroes in the selection area
var _hero_offset = Vector2(100, 100)  # Offset from top-left corner

func _ready():
	_spawn_heroes()

func _spawn_heroes():
	var episode_data = DataManager.get_episode(episode_id)
	if episode_data.is_empty():
		push_error("Failed to load episode data for: " + episode_id)
		return
		
	var available_heroes = episode_data.get("available_heroes", [])
	if available_heroes.is_empty():
		push_error("No available heroes found in episode: " + episode_id)
		return
		
	for i in range(available_heroes.size()):
		var hero = hero_scene.instantiate()
		hero.entity_id = available_heroes[i]
		add_child(hero)
		
		# Position hero in selection area
		hero.position = _hero_offset + Vector2(i * _hero_spacing, 0) 