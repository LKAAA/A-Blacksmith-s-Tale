class_name Zone extends Node2D

@export var zone_id: int
@export var transitions: Array[TransitionArea]
@export var external_inventories: Array
@export var shops: Array
@export var dialogue_objects: Array

@export var tilemap_base: TileMapLayer = null
@export var tilemap_obstacles: TileMapLayer = null

# THIS CODE is no longer disgusting. Please look with happiness
func get_external_inventories() -> Array:
	if get_tree():
		return get_tree().get_nodes_in_group("external_inventory")
	
	return []

func get_shops() -> Array:
	if get_tree():
		return get_tree().get_nodes_in_group("shop")
	return []
	

func get_dialogue_objects() -> Array:
	if get_tree():
		return get_tree().get_nodes_in_group("dialogue_object")
	return []

func get_npcs() -> Array:
	if get_tree():
		return get_tree().get_nodes_in_group("npc_character")
	return []

func get_obstacles() -> Array:
	if get_tree():
		return get_tree().get_nodes_in_group("obstacle")
	return []
