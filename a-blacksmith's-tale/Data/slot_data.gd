class_name SlotData extends Resource

const MAX_STACK_SIZE: int = 999

@export var item_data: ItemData
@export_range(0, MAX_STACK_SIZE) var quantity: int = 1: set = set_quantity


# @param other_slot_data - slot data that gets compared with the slot data on this slot
# @return bool that says whether or not this can merge 
func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
				and item_data.stackable \
				and quantity < MAX_STACK_SIZE

# @param other_slot_data - slot data that gets compared with the slot data on this slot
# @return bool that says whether or not this can fully merge 
func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
				and item_data.stackable \
				and quantity + other_slot_data.quantity <= MAX_STACK_SIZE

# Only works if there is another slot to make as well 
func can_partially_merge_with(other_slot_data: SlotData, inventory_data: InventoryData) -> bool:
	if item_data == other_slot_data.item_data and item_data.stackable and not quantity == MAX_STACK_SIZE:
		for index in inventory_data.inventory_slots.size():
			if inventory_data.inventory_slots[index].can_merge_with(other_slot_data):
				return true
	
	return false 

# @param other_slot_data - slot data that will get combined into this one
func fully_merge_with(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity

func partially_merge_with(other_slot_data: SlotData) -> SlotData:
	var other = other_slot_data.quantity
	quantity += other
	var excess = quantity - MAX_STACK_SIZE
	var created_slot_data = SlotData.new()
	created_slot_data.item_data = item_data
	created_slot_data.quantity = excess
	quantity = MAX_STACK_SIZE
	return created_slot_data

# @return A new slot that was created with a single item
func create_single_slot_data() -> SlotData:
	var created_slot_data = duplicate()
	created_slot_data.quantity = 1
	quantity -= 1
	return created_slot_data

# @param _item_data - the item data to copy into this one
# @param slot_size - the number of items to add to this new slot
func new_slot_data(_item_data: ItemData, slot_size: int):
	quantity = slot_size
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("%s is not stackable, setting quantity to one" % item_data.name)
	item_data = _item_data

# @param value - number to set this slots quantity to 
func set_quantity(value: int) ->  void:
	quantity = value
	if item_data:
		if quantity > 1 and not item_data.stackable:
			quantity = 1
			push_error("%s is not stackable, setting quantity to one" % item_data.name)
