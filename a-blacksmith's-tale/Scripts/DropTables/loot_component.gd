extends Node2D
class_name LootComponent

const ITEM_PICKUP = preload("res://Scenes/item_pickup.tscn")

func create_pickup(item_data, quantity) -> void:
	var dropped_item = ITEM_PICKUP.instantiate()
	
	get_parent().get_parent().add_child(dropped_item)
	print(item_data.name)
	print("Item: %s Quantity: %d" % [item_data.name, quantity])
	var slot_data = SlotData.new()
	
	slot_data.item_data = item_data
	slot_data.quantity = quantity

	dropped_item.slot_data = slot_data

	dropped_item.update_texture()
	dropped_item.position = Vector2(get_parent().position.x + randi_range(-10, 10), get_parent().position.y + randi_range(-10, 10))
