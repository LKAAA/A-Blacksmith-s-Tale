class_name InventoryData extends Resource

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interacted(inventory_data: InventoryData, index: int, button: int)

@export var inventory_slots: Array[SlotData] = []

func pick_up_slot_data(slot_data: SlotData) -> bool:
	for index in inventory_slots.size():
		if inventory_slots[index] and inventory_slots[index].can_fully_merge_with(slot_data):
			inventory_slots[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	for index in inventory_slots.size():
		if inventory_slots[index] and inventory_slots[index].can_partially_merge_with(slot_data, self):
			var new_slot = inventory_slots[index].partially_merge_with(slot_data)
			for i in inventory_slots.size():
				if not inventory_slots[i]:
					inventory_slots[i] = new_slot
					inventory_updated.emit(self)
					return true

	for index in inventory_slots.size():
		if not inventory_slots[index]:
			inventory_slots[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false
	

func  on_slot_clicked(index: int, button: int) -> void:
	print("emit")
	inventory_interacted.emit(self, index, button)
