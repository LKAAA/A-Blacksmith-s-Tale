class_name Inventory extends Node

@export var inventory: Array[StackData]

@export var slots: int = 27

func _ready() -> void:
	inventory.resize(slots)

# Adds item to inventory
# @param item - Item to add to inventory
# @return bool - Whether or not the item was added
func add_item(item: StackData) -> bool:
	if inventory.size() + 1 <= slots: # If you have the available slots
		inventory.append(item)
		return true # Returns that the item was picked up
	else:
		print("Inventory is full.")
		return false # Returns that the item was not picked up
