class_name Zone extends Node2D

@export var transitions: Array[TransitionArea]
@export var external_inventories: Array

# THIS CODE IS DISGUSTING - AVERT YOUR EYES
func get_external_inventories() -> Array:
	for child in get_children():
		if child.name == "Objects":
			print(child.name)
			for c in child.get_children():
				if c.is_in_group("external_inventory"):
					external_inventories.append(c)
	
	return external_inventories
