class_name InventoryData extends Resource

signal inventory_updated(inventory_data: InventoryData, index: int)
signal inventory_interacted(inventory_data: InventoryData, index: int, button: int)

@export var inventory_slots: Array[SlotData] = []

func pick_up_slot_data(slot_data: SlotData) -> bool:
	for index in inventory_slots.size():
		if inventory_slots[index] and inventory_slots[index].can_fully_merge_with(slot_data):
			inventory_slots[index].fully_merge_with(slot_data)
			inventory_updated.emit(self, index)
			return true
	
	for index in inventory_slots.size():
		if inventory_slots[index] and inventory_slots[index].can_partially_merge_with(slot_data, self):
			var new_slot = inventory_slots[index].partially_merge_with(slot_data)
			for i in inventory_slots.size():
				if not inventory_slots[i]:
					inventory_slots[i] = new_slot
					inventory_updated.emit(self, i)
					inventory_updated.emit(self, index)
					return true

	for index in inventory_slots.size():
		if not inventory_slots[index]:
			inventory_slots[index] = slot_data
			inventory_updated.emit(self, index)
			return true
	
	return false

func grab_slot_data(index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	if slot_data:
		inventory_slots[index] = null
		inventory_updated.emit(self, index)
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
		return_slot_data = slot_data
		Popups.ItemPopup(inventory_slots[index].item_data)
	
	inventory_updated.emit(self, index)
	return return_slot_data

func grab_new_single_slot_data(index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	var return_slot_data: SlotData
	if slot_data:
		return_slot_data = slot_data.create_single_slot_data()
		if inventory_slots[index].quantity < 1:
			inventory_slots[index] = null
		inventory_updated.emit(self, index)
		return return_slot_data
	else:
		return null

func remove_single_item(item_data:ItemData) -> bool:
	if not item_data:
		printerr("No item data found.")
		return false
	
	var slot_data: SlotData
	for slot in inventory_slots:
		var index = inventory_slots.find(slot)
		if slot:
			if slot.item_data == item_data:
				slot.quantity -= 1
				print(slot.quantity)
				if slot.quantity < 1:
					inventory_slots[index] = null
				inventory_updated.emit(self, index) 
				return true
	
	print("Item not here ")
	return false

func remove_items(item_data:ItemData, count: int) -> bool:
	if not item_data: 
		printerr("Inventory does not contain " + item_data.name)
		return false
	
	var remaining = count
	var slot_data: SlotData
	for slot in inventory_slots:
		var index = inventory_slots.find(slot)
		if slot:
			if slot.item_data == item_data:
				if slot.quantity >= remaining:
					slot.quantity -= remaining
					if slot.quantity < 1:
						inventory_slots[index] = null
					inventory_updated.emit(self.index)
					return true
				else:
					slot.quantity -= remaining
					if slot.quantity < 1:
						inventory_slots[index] = null
	
	return false

func grab_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = inventory_slots[index]
	if slot_data and grabbed_slot_data.quantity + 1 <= 999 and slot_data.item_data == grabbed_slot_data.item_data:
		grabbed_slot_data.quantity += 1
		slot_data.quantity -= 1
		if inventory_slots[index].quantity < 1:
			inventory_slots[index] = null
			Popups.HideItemPopup()
		inventory_updated.emit(self, index)
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
	
	inventory_updated.emit(self, index)
	
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func  on_slot_clicked(index: int, button: int) -> void:
	inventory_interacted.emit(self, index, button)
