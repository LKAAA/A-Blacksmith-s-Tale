extends Area2D
class_name BehindAdjustment

func _ready() -> void:
	#get_parent().z_index = 2
	pass

func _on_body_entered(_body: Node2D) -> void:
	_body.z_index = 1
	print("Body entered", _body.name)

func _on_body_exited(_body: Node2D) -> void:
	_body.z_index = 3
	print("Body exited", _body.name)
