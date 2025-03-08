class_name InventoryUI extends GridContainer

const SLOT = preload("res://Scenes/slot.tscn")

var inventory_slots: Array[Slot]

func set_inventory_data(inventory_data: InventoryData) -> void:
	print("Set data")
	inventory_data.inventory_updated.connect(populate_grid)
	populate_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_grid)

func populate_grid(inv: InventoryData) -> void:
	print("Update Inventory")
	for child in get_children():
		child.queue_free()
	
	for slot_data in inv.inventory_slots:
		var slot = SLOT.instantiate()
		add_child(slot)
		
		slot.slot_clicked.connect(inv.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
