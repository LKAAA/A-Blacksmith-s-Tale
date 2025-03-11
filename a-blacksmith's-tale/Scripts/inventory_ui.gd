class_name InventoryUI extends PanelContainer

const SLOT = preload("res://Scenes/slot.tscn")

@onready var grid: GridContainer = %InventoryUI

var inventory_slots: Array[Slot]

func set_inventory_data(inventory_data: InventoryData, slots_to_update: int = 36, interactable: bool = true) -> void:
	inventory_data.inventory_updated.connect(update_slot)
	populate_grid(inventory_data, slots_to_update, interactable)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(update_slot)

func update_slot(inv: InventoryData, index: int) -> void:
	inventory_slots[index].set_slot_data(inv.inventory_slots[index])

func populate_grid(inv: InventoryData, slots_to_update: int = 36, interactable: bool = true) -> void:
	for child in grid.get_children():
		child.queue_free()
		inventory_slots.clear()
	
	for index in slots_to_update:
		var slot = SLOT.instantiate()
		grid.add_child(slot)
		inventory_slots.append(slot)
		
		if interactable: 
			slot.slot_clicked.connect(inv.on_slot_clicked)
		
		if inv.inventory_slots[index]:
			slot.set_slot_data(inv.inventory_slots[index])	
