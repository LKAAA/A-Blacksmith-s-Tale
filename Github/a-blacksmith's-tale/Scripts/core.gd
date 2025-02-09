extends Node2D
class_name Core

const TEST_ZONE_1 = preload("res://TEMP/TestZones/TestZone1.tscn")
const TEST_ZONE_2 = preload("res://TEMP/TestZones/TestZone2.tscn")
const PLAYER = preload("res://Player/player.tscn")

var current_zone: Zone
var next_zone: Zone
var player: PlayerBase

func _ready() -> void:
	load_zone()

func load_zone(path: String = "", transition: int = 99) -> void:
	if !current_zone: # If there is no zone already
		print("Loading default / First zone")
		current_zone = TEST_ZONE_1.instantiate()
		add_child(current_zone)
		
		player = PLAYER.instantiate()
		current_zone.add_child(player)
	else:
		print("Loading a new zone")
		
		# If there is a zone
		next_zone = load(path).instantiate()
		call_deferred("add_child", next_zone)
		
		if player:
			player.reparent(next_zone)
			
			if transition != 99:
				player.position = next_zone.transitions[transition].position
			else:
				player.position = Vector2(0,0)
		
		if current_zone:
			current_zone.queue_free()
		
		current_zone = next_zone
		next_zone = null
	
	for t in current_zone.transitions:
		t.transition_entered.connect(load_zone)
