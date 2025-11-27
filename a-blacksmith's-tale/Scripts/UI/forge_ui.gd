extends Control
class_name ForgeUI

@onready var player_inventory: InventoryGrid = %PlayerInventory
@onready var fuel_inventory: InventoryGrid = %FuelInventory
@onready var smeltable_inventory: InventoryGrid = %SmeltableInventory

@export var smeltable_slots: Array[InventorySlot] = []
@export var fuel_slots: Array[InventorySlot] = []

@onready var temp_label: RichTextLabel = %TempLabel

var cur_forge: Forge = null
	

func set_ui(inventory_system: InventorySystem, forge: Forge) -> void:
	player_inventory.set_inventory(inventory_system)
	fuel_inventory.set_inventory(forge.fuel_inventory)
	smeltable_inventory.set_inventory(forge.smeltable_inventory)
	
	temp_label.text = "0 Celsius"
	
	cur_forge = forge
	if not cur_forge.temperature_changed.is_connected(temp_updated):
		cur_forge.temperature_changed.connect(temp_updated)

func temp_updated(new_temp: int) -> void:
	temp_label.text = "%d Celsius" % new_temp

func _on_light_forge_button_pressed() -> void:
	if cur_forge:
		cur_forge.light_forge()
