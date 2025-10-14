extends Control
class_name ForgeUI

@onready var inventory: InventoryUI = %Inventory
@onready var smeltable_inventory: InventoryUI = %SmeltableInventory
@onready var fuel_inventory: InventoryUI = %FuelInventory

@export var smeltable_slots: Array[Slot] = []
@export var fuel_slots: Array[Slot] = []

@onready var temp_label: RichTextLabel = %TempLabel

var cur_forge: Forge = null
	

func set_ui(inventory_data: InventoryData, forge: Forge) -> void:
	inventory.set_inventory_data(inventory_data, 36, true, true)
	fuel_inventory.set_inventory_data(forge.fuel_inventory, 3, true, true)
	smeltable_inventory.set_inventory_data(forge.smeltable_inventory, 2, true, true)
	
	cur_forge = forge
