extends GridContainer
class_name InventoryGrid

const INVENTORY_SLOT = preload("uid://ccmyhhc71d7ao")

var attached_inventory: InventorySystem = null

var inventory_slots: Array[InventorySlot]

func set_inventory(inventory_system: InventorySystem) -> void:
	if not inventory_system.inventory_updated.is_connected(update_slot):
		inventory_system.inventory_updated.connect(update_slot)
		populate_grid(inventory_system)
		print("Here")

func clear_inventory(inventory_system: InventorySystem) -> void:
	inventory_system.inventory_updated.disconnect(update_slot)

func update_slot(inv: InventorySystem, index: int) -> void:
	print("update slot ", index)
	if index < inventory_slots.size():
		if inv.inventory[index]:
			self.inventory_slots[index].set_item_stack(inv.inventory[index])
		else:
			self.inventory_slots[index].set_item_stack(null)
	else:
		printerr("Inventory does not have the correct size. The size is: " + str(inventory_slots.size()) + " , while the index to access is " + str(index))

func populate_grid(inventory_system: InventorySystem) -> void:
	for child in get_children():
		child.queue_free()
	
	inventory_slots.clear()
	
	attached_inventory = inventory_system
	
	for index in attached_inventory.inventory.size():
		var inv_slot: InventorySlot = INVENTORY_SLOT.instantiate()
		add_child(inv_slot)
		inv_slot.item_stack = attached_inventory.inventory[index]
		if attached_inventory.locked[index]:
			inv_slot.background.self_modulate = Color.RED
		
		inv_slot.slot_clicked.connect(inventory_system.on_slot_clicked)
		
		inventory_slots.append(inv_slot)
		
