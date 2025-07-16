class_name ItemData extends Resource

@export var name: String
@export var description: String
@export var sprite: Texture2D = preload("res://Assets/debug_texture.png")
@export var type: String = "Material"

@export var stackable: bool = true

func use(_target) -> void:
	pass
