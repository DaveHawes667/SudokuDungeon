using Godot;
using System;

public partial class GridGenerator : Node
{
	private TileMap _tileMap;
	private const int GRID_SIZE = 9;
	private const int WALL_TILE_ID = 2; // This corresponds to the wall tile in the tileset (2:0/0)
	private const int FLOOR_TILE_ID = 0; // This corresponds to the floor tile in the tileset (0:0/0)
	
	public override void _Ready()
	{
		_tileMap = GetNode<TileMap>("../TileMap");
		GenerateGrid();
	}
	
	private void GenerateGrid()
	{
		// Clear existing tiles
		_tileMap.Clear();
		
		// Generate the 9x9 grid
		for (int x = 0; x < GRID_SIZE; x++)
		{
			for (int y = 0; y < GRID_SIZE; y++)
			{
				// Place walls around the perimeter
				if (x == 0 || x == GRID_SIZE - 1 || y == 0 || y == GRID_SIZE - 1)
				{
					_tileMap.SetCell(0, new Vector2I(x, y), 0, new Vector2I(WALL_TILE_ID, 0));
				}
				else
				{
					// Place floor tiles in the interior
					_tileMap.SetCell(0, new Vector2I(x, y), 0, new Vector2I(FLOOR_TILE_ID, 0));
				}
			}
		}
	}
} 
