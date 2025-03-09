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

func grab_slot_data(index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	if slot_data:
		inventory_slots[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		inventory_slots[index] = grabbed_slot_data
		print(inventory_slots[index])
		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data

func grab_new_single_slot_data(index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	var return_slot_data: SlotData
	if slot_data:
		return_slot_data = slot_data.create_single_slot_data()
		if inventory_slots[index].quantity < 1:
			inventory_slots[index] = null
		inventory_updated.emit(self)
		return return_slot_data
	else:
		return null

func grab_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	if slot_data and grabbed_slot_data.quantity + 1 <= 999 and slot_data.item_data == grabbed_slot_data.item_data:
		grabbed_slot_data.quantity += 1
		slot_data.quantity -= 1
		if inventory_slots[index].quantity < 1:
			inventory_slots[index] = null
		inventory_updated.emit(self)
		return grabbed_slot_data
	else:
		return grabbed_slot_data

# CURRENTLY UNUSED
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	
	if not slot_data:
		inventory_slots[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func  on_slot_clicked(index: int, button: int) -> void:
	inventory_interacted.emit(self, index, button)
