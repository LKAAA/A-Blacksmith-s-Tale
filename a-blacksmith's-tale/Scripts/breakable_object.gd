extends StaticBody2D

@onready var breakable_area: Area2D = $breakable_area

#var loot_table: LootTable
var item_drop: ItemData

func _ready() -> void:
	breakable_area.hit = Callable(self, "_on_hit")

func _on_hit() -> void:
	print("hit object")
