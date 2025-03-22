extends Node

const GRID_SIZE = 9

@export var _tile_map: TileMapLayer

func _ready() -> void:
	generate_grid()

func generate_grid() -> void:
	# Create grid cells with lines
	var line_color = Color(0.5, 0.5, 0.5, 0.3) # Semi-transparent gray
	var cell_size = 32 # Tile size in pixels
	
	# Create horizontal lines
	for y in range(GRID_SIZE + 1):
		var line = Line2D.new()
		line.default_color = line_color
		line.width = 1
		line.add_point(Vector2(0, y * cell_size))
		line.add_point(Vector2(GRID_SIZE * cell_size, y * cell_size))
		add_child(line)
	
	# Create vertical lines  
	for x in range(GRID_SIZE + 1):
		var line = Line2D.new()
		line.default_color = line_color
		line.width = 1
		line.add_point(Vector2(x * cell_size, 0))
		line.add_point(Vector2(x * cell_size, GRID_SIZE * cell_size))
		add_child(line)
