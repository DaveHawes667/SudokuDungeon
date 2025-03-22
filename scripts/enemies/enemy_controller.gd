class_name EnemyController extends EntityController

const HEART_SPRITE_SCALE_FACTOR = 0.1

func _ready():
	super._ready()

	var uiScaleFactor = HEART_SPRITE_SCALE_FACTOR
	# Load and setup heart icon
	var heart_texture = load("res://sprites/ui/interface_game/heart.png")
	var heart_sprite = Sprite2D.new()
	heart_sprite.texture = heart_texture
	heart_sprite.scale = Vector2(uiScaleFactor, uiScaleFactor)
	heart_sprite.position = Vector2(0, _colliderShape.shape.size.y/2)
	add_child(heart_sprite)
	
	
	# Create label for HP value
	var hp_label = Label.new()
	hp_label.text = str(get_health())
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER	

	# Position label on top of heart
	var heart_height = heart_sprite.texture.get_height()
	hp_label.position = Vector2(-_colliderShape.shape.size.x/2.0, -heart_height/2.0)
	heart_sprite.add_child(hp_label)

# Getter methods for enemy properties
func get_health() -> int:
	return _entity_data.get("health", 0)
