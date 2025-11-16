class_name ItemStack extends Resource

@export var item_data: ItemData:
	set(data):
		item_data = data
	get:
		return item_data

@export var quantity: int = 1:
	set = set_quantity, get = get_quantity

var cur_temp: int = 0:
	set(new_temp):
		cur_temp = new_temp
	get:
		return cur_temp
@export var quality: int = 0:
	set(newquality):
		quality = newquality
	get:
		return quality
@export var durability: int = 100:
	set(new_dura):
		durability = new_dura
	get:
		return durability
@export var custom_name: String = "":
	set(new_name):
		custom_name = new_name
	get:
		return custom_name

func new_from_data(data: ItemData, new_quantity: int = 1) -> ItemStack:
	var stack = ItemStack.new()
	
	stack.item_data = data
	stack.quantity = new_quantity
	
	return stack

func modify_quantity(amount: int) -> ItemStack:
	quantity += amount
	return self

# @param value - number to set this slots quantity to 
func set_quantity(value: int) ->  void:
	quantity = value
	if item_data:
		if quantity > 1 and not item_data.stackable:
			quantity = 1
			push_error("%s is not stackable, setting quantity to one" % item_data.name)

func get_quantity() -> int:
	return quantity

func modify_cur_temp(amount: int) -> ItemStack:
	cur_temp += amount
	return self

# @param other_item_stack - item stack that gets compared with the item stack on this slot
# @return bool that says whether or not this can merge 
func can_merge_with(other_item_stack: ItemStack) -> bool:
	return item_data == other_item_stack.item_data \
				and item_data.stackable \
				and quantity < Global.MAX_STACK_SIZE

# @param other_item_stack - item stack that gets compared with the item stack on this slot
# @return bool that says whether or not this can fully merge 
func can_fully_merge_with(other_item_stack: ItemStack) -> bool:
	return item_data == other_item_stack.item_data \
				and item_data.stackable \
				and quantity + other_item_stack.quantity <= Global.MAX_STACK_SIZE

# Checks if the slot can be partially merged with, as well as checking
# If there is available inventory space for the excess
func can_partially_merge_with(other_item_stack: ItemStack, inventory_data: InventoryData) -> bool:
	if item_data == other_item_stack.item_data and item_data.stackable and not quantity == Global.MAX_STACK_SIZE:
		for index in inventory_data.inventory_slots.size():
			if inventory_data.inventory_slots[index].can_merge_with(other_item_stack):
				return true
	
	return false 

# @param other_item_stack - item stack that will get combined into this one
func fully_merge_with(other_item_stack: ItemStack) -> void:
	quantity += other_item_stack.quantity

# Used if combining two stacks will produce excess
# @param other_item_stack is the stack to merge into
func partially_merge_with(other_item_stack: ItemStack) -> ItemStack:
	var other_quan = other_item_stack.quantity
	quantity += other_quan
	var excess = quantity - Global.MAX_STACK_SIZE
	var created_item_stack = ItemStack.new()
	created_item_stack.item_data = item_data
	created_item_stack.quantity = excess
	quantity = Global.MAX_STACK_SIZE
	return created_item_stack

# @return A duplicate of this item stack that was created with only one quantity
func create_single_item_stack() -> ItemStack:
	var new_stack = duplicate()
	new_stack.quantity = 1
	return new_stack

# Creates a new Item Stack
# @param _item_data - the item data to copy into this one
# @param slot_amount - the number of items to add to this new slot
func new_item_stack(_item_data: ItemData, slot_amount: int) -> ItemStack:
	var new_stack = ItemStack.new()
	new_stack.item_data = _item_data
	new_stack.quantity = slot_amount
	if new_stack.quantity > 1 and not new_stack.item_data.stackable:
		new_stack.quantity = 1
		push_error("%s is not stackable, setting item_stack._quantity to one" % new_stack.item_data.name)
	return new_stack
