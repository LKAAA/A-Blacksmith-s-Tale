extends Control
class_name ForgeUI

@onready var inventory: InventoryUI = %Inventory

func set_ui(inventory_data: InventoryData) -> void:
	inventory.set_inventory_data(inventory_data, 36, true, true)
