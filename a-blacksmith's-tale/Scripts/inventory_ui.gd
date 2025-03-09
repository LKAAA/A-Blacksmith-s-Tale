class_name InventoryUI extends GridContainer

const SLOT = preload("res://Scenes/slot.tscn")

var inventory_slots: Array[Slot]

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(update_slot)
	populate_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(update_slot)

func update_slot(inv: InventoryData, index: int) -> void:
	inventory_slots[index].set_slot_data(inv.inventory_slots[index])

func populate_grid(inv: InventoryData) -> void:
	for child in get_children():
		child.queue_free()
		inventory_slots.clear()
	
	for slot_data in inv.inventory_slots:
		var slot = SLOT.instantiate()
		add_child(slot)
		inventory_slots.append(slot)
		
		slot.slot_clicked.connect(inv.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
