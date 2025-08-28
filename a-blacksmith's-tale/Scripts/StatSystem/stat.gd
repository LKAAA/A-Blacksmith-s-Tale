extends Resource
class_name Stat

@export var name: String
@export var base: float = 0
@export var modified_base: float = 0
@export var current: float = 0
@export var modifiers: Array[Modifier] = []
