extends ItemData
class_name ItemDataPlaceable

@export var placeable_scene: PackedScene
@export var size: Array[int]

func place(mouse_pos: Vector2) -> void:
	var placeable = Grid.check_location_walkable(mouse_pos, size)
	var in_range = Global.core.player_in_range(mouse_pos)
	if placeable and in_range:
		var object = placeable_scene.instantiate()
		Global.core.current_zone.add_child(object)
		# Really scuffed way to make sure the object is placed on the grid 
		# Converts mouse pos to the tile pos then the tile pos to local pos so its locked on the grid. 
		# Seems to work fine
		object.position = Grid.current_tilemap_base.map_to_local(Grid.get_tile_pos(mouse_pos)) 
		Global.core.update_grid(Global.core.current_zone)
		Global.player.inventory.remove_single_item(self, Global.active_slot_index)
	print(placeable)
	print("We placing now")
