class_name Breakable extends Area2D

var hovering: bool = false

var hit: Callable = func():
	pass

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false
