class_name Interactable extends Area2D

var hovering: bool = false

var interact: Callable = func():
	pass

# REMEMBER TO CONNECT SIGNALS WHEN MAKING NEW OBJECT

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false
