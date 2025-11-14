class_name SlotData extends Resource

@export var item_stack: ItemStack
@export var locked: bool = false

# @param other_slot_data - slot data that gets compared with the slot data on this slot
# @return bool that says whether or not this can merge 
func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_stack.item_data == other_slot_data.item_stack.item_data \
				and item_stack.item_data.stackable \
				and item_stack._quantity < Global.MAX_STACK_SIZE

# @param other_slot_data - slot data that gets compared with the slot data on this slot
# @return bool that says whether or not this can fully merge 
func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_stack.item_data == other_slot_data.item_stack.item_data \
				and item_stack.item_data.stackable \
				and item_stack._quantity + other_slot_data.item_stack._quantity <= Global.MAX_STACK_SIZE

# Only works if there is another slot to make as well 
func can_partially_merge_with(other_slot_data: SlotData, inventory_data: InventoryData) -> bool:
	if item_stack.item_data == other_slot_data.item_stack.item_data and item_stack.item_data.stackable and not item_stack._quantity == Global.MAX_STACK_SIZE:
		for index in inventory_data.inventory_slots.size():
			if inventory_data.inventory_slots[index].can_merge_with(other_slot_data):
				return true
	
	return false 

# @param other_slot_data - slot data that will get combined into this one
func fully_merge_with(other_slot_data: SlotData) -> void:
	item_stack._quantity += other_slot_data.item_stack._quantity

func partially_merge_with(other_slot_data: SlotData) -> SlotData:
	var other = other_slot_data.item_stack._quantity
	item_stack._quantity += other
	var excess = item_stack._quantity - Global.MAX_STACK_SIZE
	var created_slot_data = SlotData.new()
	created_slot_data.item_stack.item_data = item_stack.item_data
	created_slot_data.item_stack._quantity = excess
	item_stack._quantity = Global.MAX_STACK_SIZE
	return created_slot_data

# @return A new slot that was created with a single item
func create_single_slot_data() -> SlotData:
	var created_slot_data = duplicate()
	created_slot_data.item_stack._quantity = 1
	item_stack._quantity -= 1
	return created_slot_data

# @param _item_data - the item data to copy into this one
# @param slot_size - the number of items to add to this new slot
func new_slot_data(_item_data: ItemData, slot_size: int):
	item_stack._quantity = slot_size
	if item_stack._quantity > 1 and not item_stack.item_data.stackable:
		item_stack._quantity = 1
		push_error("%s is not stackable, setting item_stack._quantity to one" % item_stack.item_data.name)
	item_stack.item_data = _item_data
