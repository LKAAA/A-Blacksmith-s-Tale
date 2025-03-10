class_name Chest extends StaticBody2D 

@onready var interactable: Interactable = $Interactable

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

func _ready() -> void:
	interactable.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	toggle_inventory.emit(self)
	print("Open Chest")
