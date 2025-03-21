class_name HeroController extends EntityController


func _process(delta):
	# Example of state changes based on movement
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		set_state("walk")
	else:
		set_state("idle") 
