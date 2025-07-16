class_name DialogueInteraction extends StaticBody2D 

@onready var interact_area: Interactable = $InteractArea

signal request_dialogue()

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	request_dialogue.emit()
	print("Interact with ")
