class_name ItemStack extends Resource

var item_data: ItemData:
	set(data):
		item_data = data
	get:
		return item_data

var quantity: int = 1:
	set = set_quantity, get = get_quantity

var cur_temp: int = 0:
	set(new_temp):
		cur_temp = new_temp
	get:
		return cur_temp
var quality: int = 0:
	set(newquality):
		quality = newquality
	get:
		return quality
var durability: int = 100:
	set(new_dura):
		durability = new_dura
	get:
		return durability
var custom_name: String = "":
	set(new_name):
		custom_name = new_name
	get:
		return custom_name

func new_from_data(data: ItemData, quantity: int = 1) -> ItemStack:
	var stack = ItemStack.new()
	
	stack.item_data = data
	stack.quantity = quantity
	
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
