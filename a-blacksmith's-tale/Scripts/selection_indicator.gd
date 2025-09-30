extends TileMapLayer

var mouse_pos: Vector2

func _physics_process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	mouse_pos = Vector2(mouse_pos.x - 8, mouse_pos.y - 8)
	var mouse_tile = local_to_map(mouse_pos)
	
	update_selection_tile(mouse_tile)

func get_mouse_pos_tile() -> Vector2:
	return local_to_map(mouse_pos)

func update_selection_tile(mouse_tile: Vector2) -> void:
	clear()
	set_cell(mouse_tile, 0, Vector2(0,0))
