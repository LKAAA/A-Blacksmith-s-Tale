extends Area2D
class_name TransitionArea

signal transition_entered(next_zone_path, next_zone_num)

@export var next_zone: String
@export var next_zone_num: int

# When entered by the player, set monitoring to false, not alloweding it to be interacted with anymore
# Then emit the transition_entered signal with the path to the scene to transition to
# And the number of the transition to teleport the player to. This number coresponds to the location in
# The transition array of each zone
func _on_body_entered(body: Node2D) -> void:
	if next_zone:
		set_deferred("monitoring", false)
		transition_entered.emit(next_zone, next_zone_num)
