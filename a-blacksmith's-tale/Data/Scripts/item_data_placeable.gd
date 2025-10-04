extends ItemData
class_name ItemDataPlaceable

@export var placeable_scene: PackedScene
@export var size: Array[int]

func place(mouse_pos: Vector2) -> void:
	var placeable = Grid.check_location_walkable(mouse_pos, size)
	print(placeable)
	print("We placing now")
