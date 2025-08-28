extends Resource
class_name Modifier

@export_enum("FLAT", "PERCENTAGE") var type: String = "FLAT"
@export var value: float
@export var name: String
@export var starting_duration: float = -1 # -1 for permanent
@export var remaining_duration: float

@export var active: bool = false
