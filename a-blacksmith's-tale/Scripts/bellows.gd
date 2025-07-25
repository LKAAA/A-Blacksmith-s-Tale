extends Node2D
class_name BellowsManager

@onready var interact_area_bellows: Interactable = $"../InteractArea_Bellows"

signal bellows_interacted

func _ready() -> void:
	interact_area_bellows.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print("Interacted with bellows")
	bellows_interacted.emit()
