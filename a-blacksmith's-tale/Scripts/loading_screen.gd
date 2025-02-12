extends Control
class_name LoadingScreen
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer

signal fade_in_finished

# Starts the fade in animation
func fade_in() -> void:
	animation_player.play("Fade_In")

# Starts the fade out animation
func fade_out() -> void:
	animation_player.play("Fade_Out")

# When fade in is finished playing, emit signal fade_in_finished
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fade_In":
		fade_in_finished.emit()
