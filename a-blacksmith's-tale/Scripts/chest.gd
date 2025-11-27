class_name Chest extends StaticBody2D 

@onready var interact_area: Interactable = $InteractArea

signal toggle_inventory(external_inventory_owner)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	toggle_inventory.emit(self)
	print("Open Chest")
