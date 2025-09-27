extends Area2D
class_name BehindAdjustment

func _ready() -> void:
	get_parent().z_index = 0

func _on_body_entered(_body: Node2D) -> void:
	get_parent().z_index = 3


func _on_body_exited(_body: Node2D) -> void:
	get_parent().z_index = 0
