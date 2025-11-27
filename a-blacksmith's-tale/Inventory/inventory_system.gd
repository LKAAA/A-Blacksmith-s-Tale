extends Node2D
class_name InventorySystem

signal inventory_updated(inventory_system: InventorySystem, index: int)
signal inventory_interacted(inventory_system: InventorySystem, index: int, button: int)

@export var inventory: Array[ItemStack]
@export var locked: Array[bool]
@export var inventory_slots: int = 36
@export var locked_slots: int = 0

func _ready() -> void:
	populate_inventory(inventory_slots)

func populate_inventory(inv_slots: int) -> bool:
	inventory.resize(inv_slots)
	locked.resize(inv_slots)
	for i in range(locked_slots):
		print(i)
		locked[i] = true
	
	locked.reverse()
	
	return true

func add_item_stack(item_stack: ItemStack) -> bool:
	if not item_stack: 
		return false
	
	if not can_place_item_stack(item_stack):
		return false
	
	for index in inventory.size():
		var slot = inventory[index]
		if slot and slot.can_fully_merge_with(item_stack):
			slot.fully_merge_with(item_stack)
			inventory_updated.emit(self, index)
			return true
	
	for index in range(inventory.size()): 
		var slot = inventory[index]
		if slot and slot.can_partially_merge_with(item_stack, self):
			
			var leftover = slot.partially_merge_with(item_stack)
			inventory_updated.emit(self, index)
			
			if leftover.quantity == 0:
				return true
			
			item_stack = leftover
	
	for index in inventory.size():
		if not inventory[index] and not locked[index]:
			inventory[index] = item_stack
			inventory_updated.emit(self, index)
			return true
	
	print("Item Stack has ", item_stack.quantity, " left in it")
	
	return false

func can_place_item_stack(item_stack: ItemStack) -> bool:
	if not item_stack: 
		return false
	
	for index in inventory.size():
		if not inventory[index] and not locked[index]:
			return true
	
	for index in inventory.size():
		if inventory[index] and not locked[index]:
			if inventory[index].can_fully_merge_with(item_stack):
				return true
	
	for index in inventory.size():
		if inventory[index] and not locked[index]:
			if inventory[index].can_partially_merge_with(item_stack, self):
				var leftover = inventory[index].partially_merge_with(item_stack)
				if leftover: 
					for other_index in inventory.size():
						if not inventory[other_index] and not locked[other_index]:
							return true
				return true
	
	return false

func grab_item_stack(index: int) -> ItemStack:
	var item_stack = inventory[index]
	if item_stack:
		inventory[index] = null
		print("Returning Emitting")
		inventory_updated.emit(self, index)
		return item_stack
	else:
		print("Returning Null")
		return null

func grab_new_single_item_stack(index: int) -> ItemStack:
	var item_stack = inventory[index]
	var return_item_stack: ItemStack
	if item_stack:
		return_item_stack = item_stack.create_single_item_stack()
		item_stack.quantity -= 1
		if inventory[index].quantity < 1:
			inventory[index] = null
		inventory_updated.emit(self, index)
		return return_item_stack
	else:
		return null

func add_item_data(item_data: ItemData, quantity: int = 1) -> bool:
	print("Excess ", quantity)
	var excess = quantity
	while excess > 0:
		if excess > ItemManager.MAX_STACK_SIZE:
			excess -= ItemManager.MAX_STACK_SIZE
			var item_stack = create_item_stack(item_data, ItemManager.MAX_STACK_SIZE)
			if not add_item_stack(item_stack):
				return false
		else:
			var item_stack = create_item_stack(item_data, excess)
			if not add_item_stack(item_stack):
					return false
			excess = 0
	
	return true

func grab_single_item_stack(grabbed_item_stack: ItemStack, index: int) -> ItemStack:
	var item_stack = inventory[index]
	if item_stack and grabbed_item_stack.quantity + 1 <= grabbed_item_stack.item_data.stack_size and item_stack.item_data == grabbed_item_stack.item_data:
		grabbed_item_stack.quantity += 1
		item_stack.quantity -= 1
		if inventory[index].quantity < 1:
			inventory[index] = null
			Popups.hide_item_popup()
		inventory_updated.emit(self, index)
	
	return grabbed_item_stack

func drop_item_stack(grabbed_item_stack: ItemStack, index: int) -> ItemStack:
	var item_stack = inventory[index]
	
	var return_item_stack: ItemStack
	if item_stack and item_stack.can_fully_merge_with(grabbed_item_stack):
		item_stack.fully_merge_with(grabbed_item_stack)
	else:
		inventory[index] = grabbed_item_stack
		return_item_stack = item_stack
		Popups.show_item_popup(inventory[index].item_data)
	
	inventory_updated.emit(self, index)
	return return_item_stack

func quick_move_stack(index: int, other_inventory: InventorySystem) -> bool:
	var item_stack = inventory[index]
	if not item_stack:
		return false
	
	if other_inventory.add_item_stack(item_stack):
		inventory[index] = null
		inventory_updated.emit(self, index)
		return true
	
	return false

func create_item_stack(item_data: ItemData, quantity: int = 1) -> ItemStack: 
	var item_stack = ItemStack.new()
	
	item_stack.item_data = item_data
	item_stack.quantity = quantity
	
	return item_stack

func remove_single_item(item_data: ItemData, index: int = -1) -> bool:
	if not item_data:
		printerr("No item data found.")
		return false
	
	if index == -1: 
		for stack in inventory:
			var i = inventory.find(stack)
			if stack:
				if stack.item_data == item_data:
					stack.quantity -= 1
					if stack.quantity < 1:
						inventory[i] = null
					inventory_updated.emit(self, i) 
					return true
	else:
		var stack = inventory[index]
		stack.quantity -= 1
		if stack.quantity < 1:
			inventory[index] = null
		inventory_updated.emit(self, index) 
		return true
	
	printerr("Item not here ")
	return false

func remove_items(item_data: ItemData, count: int) -> bool:
	if not item_data: 
		printerr("Inventory does not contain " + item_data.name)
		return false
	
	var remaining = count
	for stack in inventory:
		var index = inventory.find(stack)
		if stack:
			if stack.item_data == item_data:
				if stack.quantity >= remaining:
					stack.quantity -= remaining
					if stack.quantity < 1:
						inventory[index] = null
					inventory_updated.emit(self.index)
					return true
				else:
					stack.quantity -= remaining
					if stack.quantity < 1:
						inventory[index] = null
	
	return false
func has_open_slots() -> bool:
	return inventory.size() < inventory_slots

func on_slot_clicked(index: int, button: int) -> void:
	print("index ", index)
	inventory_interacted.emit(self, index, button)
