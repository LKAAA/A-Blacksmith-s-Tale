extends Node
class_name PathfindingGrid

var current_tilemap_base: TileMapLayer = null
var current_tilemap_obstacles: TileMapLayer = null

var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()
var path_to_position: Array = []

func _ready() -> void:
	pathfinding_grid.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # TEST THIS 
	pathfinding_grid.update()

func update_tilemaps(tilemap_base, tilemap_obstacles) -> void:
	current_tilemap_base = tilemap_base
	current_tilemap_obstacles = tilemap_obstacles
	
	set_grid()

func set_grid() -> void:
	pathfinding_grid.region = current_tilemap_base.get_used_rect()
	pathfinding_grid.update()
	
	for cell in current_tilemap_base.get_used_cells():
		pathfinding_grid.set_point_solid(cell, false)
	
	for cell in current_tilemap_obstacles.get_used_cells():
		pathfinding_grid.set_point_solid(cell, false)

func get_path_to_pos(starting_position, target_position) -> PackedVector2Array:
	print(starting_position)
	print(target_position)
	return pathfinding_grid.get_point_path(starting_position / Global.TILE_SIZE, target_position / Global.TILE_SIZE)
