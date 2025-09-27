class_name InventoryData extends Resource

signal inventory_updated(inventory_data: InventoryData, index: int)
signal inventory_interacted(inventory_data: InventoryData, index: int, button: int)

@export var inventory_slots: Array[SlotData] = []

func pick_up_slot_data(slot_data: SlotData) -> bool:
	if not slot_data:
		return false
	
	if not can_place_slot_data(slot_data):
		return false
	
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

func can_place_slot_data(slot_data: SlotData) -> bool:
	if not slot_data:
		return false
	
	for slot in inventory_slots:
		if slot and not slot.locked:
			if slot.can_fully_merge_with(slot_data):
				return true
	
	# 2. Can partially merge (and leftover can fit into an empty unlocked slot)?
	for slot in inventory_slots:
		if slot and not slot.locked:
			if slot.can_partially_merge_with(slot_data, self):
				# simulate leftover creation
				var leftover = slot.partially_merge_with(slot_data)
				if leftover:
					for other_slot in inventory_slots:
						if not other_slot and not leftover.locked: # empty + not locked
							return true
	
	for slot in inventory_slots:
		if not slot:
			if inventory_slots.find(slot) >= Progression.unlocked_inventory_slots:
				print("Slot is locked")
			else:
				return true
	
	# 3. Only locked slots available
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

func remove_single_item(item_data:ItemData, index: int = -1) -> bool:
	if not item_data:
		printerr("No item data found.")
		return false
	
	if index == -1: 
		for slot in inventory_slots:
			var i = inventory_slots.find(slot)
			if slot:
				if slot.item_data == item_data:
					slot.quantity -= 1
					print(slot.quantity)
					if slot.quantity < 1:
						inventory_slots[i] = null
					inventory_updated.emit(self, i) 
					return true
	else:
		var slot = inventory_slots[index]
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

func quick_move_data(index: int, other_inventory: InventoryData) -> bool:
	var slot_data = inventory_slots[index]
	if not slot_data:
		return false
	
	if other_inventory.pick_up_slot_data(slot_data):
		inventory_slots[index] = null
		inventory_updated.emit(self, index)
		return true
	
	return false

func  on_slot_clicked(index: int, button: int) -> void:
	inventory_interacted.emit(self, index, button)
