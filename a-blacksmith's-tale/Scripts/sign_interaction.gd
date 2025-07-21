class_name SignInteraction extends StaticBody2D

@onready var interact_area: Interactable = $InteractArea

@export var dialogue_tag: String
@export var dialogue_file: String
@export var dialogue_instant: bool = true

signal request_dialogue(object)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	request_dialogue.emit(self)
	print("Interact with ")
