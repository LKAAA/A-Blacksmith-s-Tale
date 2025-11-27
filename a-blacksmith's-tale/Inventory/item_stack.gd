extends Resource
class_name ItemStack

signal item_data_changed(new_item_Data: ItemData)
signal quantity_changed(new_quantity: int)

@export var item_data: ItemData:
	set(data):
		item_data = data
		item_data_changed.emit(item_data)
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

func can_merge_with(other_item_stack: ItemStack) -> bool:
	return item_data == other_item_stack.item_data \
				and item_data.stackable \
				and quantity < ItemManager.MAX_STACK_SIZE

func can_fully_merge_with(other_item_stack: ItemStack) -> bool:
	return item_data == other_item_stack.item_data \
				and quantity + other_item_stack.quantity <= ItemManager.MAX_STACK_SIZE \
				and item_data.stack_size > 1

func can_partially_merge_with(other_item_stack: ItemStack, inventory_system: InventorySystem) -> bool:
	if item_data != other_item_stack.item_data:
		return false
	if item_data.stack_size <= 1:
		return false
	if quantity >= ItemManager.MAX_STACK_SIZE:
		return false
	
	# If this stack can absorb ANY items from the other, it is a valid partial merge
	return true
	
	#if item_data == other_item_stack.item_data \
				#and item_data.stack_size > 1 \
				#and not quantity == ItemManager.MAX_STACK_SIZE:
		#print("passed check one")
		#if inventory_system.has_open_slots(): 
			#for index in inventory_system.inventory.size():
				#if inventory_system.inventory[index].can_merge_with(other_item_stack):
					#return true
	#print("returning false")
	#return false

# @param other_item_stack - item stack that will get combined into this one
func fully_merge_with(other_item_stack: ItemStack) -> void:
	quantity += other_item_stack.quantity

# Used if combining two stacks will produce excess
# @param other_item_stack is the stack to merge into
func partially_merge_with(other_item_stack: ItemStack) -> ItemStack:
	var other_quan = other_item_stack.quantity
	quantity += other_quan
	var excess = quantity - ItemManager.MAX_STACK_SIZE
	var created_item_stack = ItemStack.new()
	created_item_stack.item_data = item_data
	created_item_stack.quantity = excess
	quantity = ItemManager.MAX_STACK_SIZE
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

func modify_quantity(amount: int) -> ItemStack:
	quantity += amount
	quantity_changed.emit(quantity)
	return self

# @param value - number to set this slots quantity to 
func set_quantity(value: int) ->  void:
	print("Set Quantity")
	quantity = value
	if item_data:
		if item_data.stack_size == 1 and quantity > item_data.stack_size:
			quantity = item_data.stack_size
			push_error("%s is not stackable, setting quantity to one" % item_data.pretty_name)
	
	quantity_changed.emit(quantity)

func get_quantity() -> int:
	return quantity
