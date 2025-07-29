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
	if index < inventory_slots.size():
		print(self.name)
		self.inventory_slots[index].set_slot_data(inv.inventory_slots[index])
	else:
		print(self.name)
		printerr("Inventory does not have the correct size. The size is: " + str(inventory_slots.size()) + " , while the index to access is " + str(index))
		print("swear to god if this is you hotbar inventory i will fuck you up")

func populate_grid(inv: InventoryData, slots_to_update: int = 36, interactable: bool = true) -> void:
	for child in grid.get_children():
		child.queue_free()
	
	inventory_slots.clear()   
	
	
	
	print("Slots to update: " + str(slots_to_update))
	for index in range(slots_to_update):
		var slot = SLOT.instantiate()
		grid.add_child(slot)
		inventory_slots.append(slot)
		
		if interactable: 
			slot.slot_clicked.connect(inv.on_slot_clicked)
		
		if inv.inventory_slots[index]:
			slot.set_slot_data(inv.inventory_slots[index])
	
	size.y = 88.0
	
	if not inv.inventory_slots.size() == inventory_slots.size():
		printerr("Something went wrong, there aren't enough slots")
		print(self.name)
	else:
		print("We chill af")
