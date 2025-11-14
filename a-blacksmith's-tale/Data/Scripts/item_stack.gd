class_name ItemStack extends Resource

var _item_data: ItemData:
	set(data):
		_item_data = data
	get:
		return _item_data

var _quantity: int = 1:
	set = set_quantity, get = get_quantity

var _cur_temp: int = 0:
	set(new_temp):
		_cur_temp = new_temp
	get:
		return _cur_temp
var _quality: int = 0:
	set(new_quality):
		_quality = new_quality
	get:
		return _quality
var _durability: int = 100:
	set(new_dura):
		_durability = new_dura
	get:
		return _durability
var _custom_name: String = "":
	set(new_name):
		_custom_name = new_name
	get:
		return _custom_name

func new_from_data(data: ItemData, quantity: int = 1) -> ItemStack:
	var stack = ItemStack.new()
	
	stack._item_data = data
	stack._quantity = quantity
	
	return stack

func modify_quantity(amount: int) -> ItemStack:
	_quantity += amount
	return self

# @param value - number to set this slots quantity to 
func set_quantity(value: int) ->  void:
	_quantity = value
	if _item_data:
		if _quantity > 1 and not _item_data.stackable:
			_quantity = 1
			push_error("%s is not stackable, setting quantity to one" % _item_data.name)

func get_quantity() -> int:
	return _quantity

func modify_cur_temp(amount: int) -> ItemStack:
	_cur_temp += amount
	return self
