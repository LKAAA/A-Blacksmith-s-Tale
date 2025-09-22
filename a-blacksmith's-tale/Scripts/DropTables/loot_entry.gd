extends Resource
class_name LootEntry

@export var item_data: ItemData
@export var weight: int = 1 			# Weighted mode
@export var drop_chance: float = 1.0	# Independent mode
@export var amount_low: int = 1
@export var amount_high: int = 1
