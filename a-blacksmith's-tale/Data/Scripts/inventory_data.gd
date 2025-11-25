class_name InventoryData extends Resource

signal inventory_updated(inventory_data: InventoryData, index: int)
signal inventory_interacted(inventory_data: InventoryData, index: int, button: int)

@export var inventory_slots_stacks: Array[ItemStack] = []

func pick_up_item_stack(item_stack: ItemStack) -> bool:
	if not item_stack:
		print("Not item stack")
		return false
	
	if not can_place_item_stack(item_stack):
		return false
	
	for index in inventory_slots_stacks.size():
		if inventory_slots_stacks[index] and inventory_slots_stacks[index].can_fully_merge_with(item_stack):
			inventory_slots_stacks[index].fully_merge_with(item_stack)
			inventory_updated.emit(self, index)
			return true
	
	for index in inventory_slots_stacks.size():
		if inventory_slots_stacks[index] and inventory_slots_stacks[index].can_partially_merge_with(item_stack, self):
			var new_stack = inventory_slots_stacks[index].partially_merge_with(item_stack)
			for i in inventory_slots_stacks.size():
				if not inventory_slots_stacks[i]:
					inventory_slots_stacks[i] = new_stack
					inventory_updated.emit(self, i)
					inventory_updated.emit(self, index)
					return true

	for index in inventory_slots_stacks.size():
		if not inventory_slots_stacks[index]:
			inventory_slots_stacks[index] = item_stack
			inventory_updated.emit(self, index)
			return true
	
	return false

func can_place_item_stack(item_stack: ItemStack) -> bool:
	if not item_stack:
		return false
	
	for stack in inventory_slots_stacks:
		if stack: 
			if stack.can_fully_merge_with(item_stack):
				return true
	
	# 2. Can partially merge (and leftover can fit into an empty unlocked stack)?
	for stack in inventory_slots_stacks:
		if stack:
			if stack.can_partially_merge_with(item_stack, self):
				# simulate leftover creation
				var leftover = stack.partially_merge_with(item_stack)
				if leftover:
					for other_stack in inventory_slots_stacks:
						if not other_stack: 
							return true
	
	return false

func grab_item_stack(index: int) -> ItemStack:
	var item_stack = inventory_slots_stacks[index]
	if item_stack:
		inventory_slots_stacks[index] = null
		print("Returning Emitting")
		inventory_updated.emit(self, index)
		return item_stack
	else:
		print("Returning Null")
		return null

func drop_item_stack(grabbed_item_stack: ItemStack, index: int) -> ItemStack:
	var item_stack = inventory_slots_stacks[index]
	
	var return_item_stack: ItemStack
	if item_stack and item_stack.can_fully_merge_with(grabbed_item_stack):
		item_stack.fully_merge_with(grabbed_item_stack)
	else:
		inventory_slots_stacks[index] = grabbed_item_stack
		return_item_stack = item_stack
		Popups.ItemPopup(inventory_slots_stacks[index].item_data)
	
	inventory_updated.emit(self, index)
	return return_item_stack

func grab_new_single_item_stack(index: int) -> ItemStack:
	var item_stack = inventory_slots_stacks[index]
	var return_item_stack: ItemStack
	if item_stack:
		return_item_stack = item_stack.create_single_item_stack()
		item_stack.quantity -= 1
		if inventory_slots_stacks[index].quantity < 1:
			inventory_slots_stacks[index] = null
		inventory_updated.emit(self, index)
		return return_item_stack
	else:
		return null

func remove_single_item(item_data:ItemData, index: int = -1) -> bool:
	if not item_data:
		printerr("No item data found.")
		return false
	
	if index == -1: 
		for stack in inventory_slots_stacks:
			var i = inventory_slots_stacks.find(stack)
			if stack:
				if stack.item_data == item_data:
					stack.quantity -= 1
					if stack.quantity < 1:
						inventory_slots_stacks[i] = null
					inventory_updated.emit(self, i) 
					return true
	else:
		var stack = inventory_slots_stacks[index]
		stack.quantity -= 1
		if stack.quantity < 1:
			inventory_slots_stacks[index] = null
		inventory_updated.emit(self, index) 
		return true
	
	printerr("Item not here ")
	return false

func remove_items(item_data:ItemData, count: int) -> bool:
	if not item_data: 
		printerr("Inventory does not contain " + item_data.name)
		return false
	
	var remaining = count
	for stack in inventory_slots_stacks:
		var index = inventory_slots_stacks.find(stack)
		if stack:
			if stack.item_data == item_data:
				if stack.quantity >= remaining:
					stack.quantity -= remaining
					if stack.quantity < 1:
						inventory_slots_stacks[index] = null
					inventory_updated.emit(self.index)
					return true
				else:
					stack.quantity -= remaining
					if stack.quantity < 1:
						inventory_slots_stacks[index] = null
	
	return false

func grab_single_item_stack(grabbed_item_stack: ItemStack, index: int) -> ItemStack:
	var item_stack = inventory_slots_stacks[index]
	if item_stack and grabbed_item_stack.quantity + 1 <= 999 and item_stack.item_data == grabbed_item_stack.item_data:
		grabbed_item_stack.quantity += 1
		item_stack.quantity -= 1
		if inventory_slots_stacks[index].quantity < 1:
			inventory_slots_stacks[index] = null
			Popups.HideItemPopup()
		inventory_updated.emit(self, index)
	
	return grabbed_item_stack

# CURRENTLY UNUSED
func drop_single_item_stack(grabbed_item_stack: ItemStack, index: int) -> ItemStack:
	var item_stack = inventory_slots_stacks[index]
	
	if not item_stack:
		inventory_slots_stacks[index] = grabbed_item_stack.create_single_item_stack()
	elif item_stack.can_merge_with(grabbed_item_stack):
		item_stack.fully_merge_with(grabbed_item_stack.create_single_item_stack())
	
	inventory_updated.emit(self, index)
	
	if grabbed_item_stack.quantity > 0:
		return grabbed_item_stack
	else:
		return null

func quick_move_stack(index: int, other_inventory: InventoryData) -> bool:
	var item_stack = inventory_slots_stacks[index]
	if not item_stack:
		return false
	
	if other_inventory.pick_up_item_stack(item_stack):
		inventory_slots_stacks[index] = null
		inventory_updated.emit(self, index)
		return true
	
	return false

func  on_slot_clicked(index: int, button: int) -> void:
	print("index ", index)
	inventory_interacted.emit(self, index, button)

func get_index_of_item(item_data: ItemData) -> int:
	for stack in inventory_slots_stacks:
		if stack.item_data == item_data:
			return inventory_slots_stacks.find(stack)
	
	return -1
