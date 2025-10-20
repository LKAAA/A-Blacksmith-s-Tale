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
	
	temp_label.text = "0 Celsius"
	
	cur_forge = forge
	if not cur_forge.temperature_changed.is_connected(temp_updated):
		cur_forge.temperature_changed.connect(temp_updated)

func temp_updated(new_temp: int) -> void:
	temp_label.text = "%d Celsius" % new_temp

func _on_light_forge_button_pressed() -> void:
	if cur_forge:
		cur_forge.light_forge()
