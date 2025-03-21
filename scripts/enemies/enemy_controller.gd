class_name EnemyController extends EntityController

func _ready():
	_load_entity_data()
	_setup_sprite()


func _process(delta):
	# Example of state changes based on movement
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		set_state("walk_attack")
	else:
		set_state("idle")

# Getter methods for enemy properties
func get_health() -> int:
	return _entity_data.get("health", 0)

func get_attack() -> int:
	return _entity_data.get("attack", 0)

func get_defense() -> int:
	return _entity_data.get("defense", 0)

func get_movement_range() -> int:
	return _entity_data.get("movement_range", 0)

func get_abilities() -> Array:
	return _entity_data.get("abilities", []) 
