extends StaticBody2D
class_name MarketStall

@onready var interact_area: Interactable = $InteractArea

signal toggle_shop(data)

@export var shop_data: ShopData

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	toggle_shop.emit(shop_data)
	print("Open Shop")
