extends CharacterBody2D
class_name NPCCore

@export var char_name: String = ""

@onready var interact_area: Interactable = $InteractArea

signal request_dialogue(object)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	request_dialogue.emit(self)
	print("Interact with " + char_name)
