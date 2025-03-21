extends Node

const GRID_SIZE = 9
const WALL_TILE_ID = 2  # This corresponds to the wall tile in the tileset (2:0/0)
const FLOOR_TILE_ID = 0  # This corresponds to the floor tile in the tileset (0:0/0)

@onready var _tile_map: TileMap = $"../TileMap"

func _ready() -> void:
	generate_grid()

func generate_grid() -> void:
	# Clear existing tiles
	_tile_map.clear()
	
	# Generate the 9x9 grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			# Place walls around the perimeter
			if x == 0 or x == GRID_SIZE - 1 or y == 0 or y == GRID_SIZE - 1:
				_tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(WALL_TILE_ID, 0))
			else:
				# Place floor tiles in the interior
				_tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(FLOOR_TILE_ID, 0)) 
