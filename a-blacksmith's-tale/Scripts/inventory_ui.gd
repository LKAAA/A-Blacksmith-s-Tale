class_name InventoryUI extends PanelContainer

const SLOT = preload("res://Scenes/slot.tscn")

@onready var grid: GridContainer = %InventoryUI

var inventory_slots_ui: Array[Slot]

func set_inventory_data(inventory_data: InventoryData, slots_to_update: int = 36, locked_slots: bool = false, interactable: bool = true) -> void:
	if not inventory_data.inventory_updated.is_connected(update_slot):
		inventory_data.inventory_updated.connect(update_slot)
		populate_grid(inventory_data, slots_to_update, locked_slots, interactable)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(update_slot)

func update_slot(inv: InventoryData, index: int) -> void:
	print("update slot ", index)
	if index < inventory_slots_ui.size():
		if inv.inventory_slots_stacks[index]:
			self.inventory_slots_ui[index].set_item_stack(inv.inventory_slots_stacks[index])
		else:
			self.inventory_slots_ui[index].set_item_stack(null)
	else:
		printerr("Inventory does not have the correct size. The size is: " + str(inventory_slots_ui.size()) + " , while the index to access is " + str(index))

func populate_grid(inv: InventoryData, slots_to_update: int = 36, locked_slots: bool = false, interactable: bool = true) -> void:
	for child in grid.get_children():
		child.queue_free()
	
	var remaining_unlocked_slots: int
	
	if locked_slots: 
		remaining_unlocked_slots = Progression.unlocked_inventory_slots
	else:
		remaining_unlocked_slots = slots_to_update
	
	inventory_slots_ui.clear()   
	
	for index in range(slots_to_update):
		var slot: Slot = SLOT.instantiate()
		
		if remaining_unlocked_slots <= 0:
			slot.set_locked(true)
		
		grid.add_child(slot)
		inventory_slots_ui.append(slot)
		
		if interactable: 
			slot.slot_clicked.connect(inv.on_slot_clicked)
		
		if index >= 0 and index < inv.inventory_slots_stacks.size():
			if inv.inventory_slots_stacks[index]:
				slot.update_slot(inv.inventory_slots_stacks[index])
				if slot.locked:
					slot.locked = true
		
		remaining_unlocked_slots -= 1
	
	if not inv.inventory_slots_stacks.size() == inventory_slots_ui.size():
		printerr("Something went wrong in ", self.name, ", There aren't enough slots")
