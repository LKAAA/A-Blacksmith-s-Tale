extends Node2D
class_name ForgeManager

@onready var interact_area_forge: Interactable = $"../InteractArea_Forge"

signal forge_interacted

func _ready() -> void:
	interact_area_forge.interact = Callable(self, "_on_interact")
	
func _on_interact() -> void:
	print("Interacted with forge")
	forge_interacted.emit()
