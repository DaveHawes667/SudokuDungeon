class_name HeroController extends EntityController

func _load_entity_data():
	_entity_data = DataManager.get_hero(entity_id)
	if _entity_data.is_empty():
		push_error("Failed to load hero data for ID: " + entity_id)
		return
	
	_animations = _entity_data.get("animations", {})
	if _animations.is_empty():
		push_error("No animations found for hero: " + entity_id)

func _process(delta):
	# Example of state changes based on movement
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		set_state("walk")
	else:
		set_state("idle") 