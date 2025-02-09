extends Area2D
class_name TransitionArea

signal transition_entered(next_zone_path, next_zone_num)

@export var next_zone: String
@export var next_zone_num: int

func _on_body_entered(body: Node2D) -> void:
	if next_zone:
		print("Emit signal")
		transition_entered.emit(next_zone, next_zone_num)
