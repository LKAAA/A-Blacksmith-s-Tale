class_name StackData extends Resource

@export var item: ItemData
@export_range(0, 999) var count: int

func StackData(i: ItemData, c: int):
	self.item = i
	self.count = c

func set_item(i: ItemData) -> void:
	self.item = i

func set_count(c: int) -> void:
	self.count = c

func get_count() -> int:
	return self.count

func get_item() -> ItemData:
	return self.item
