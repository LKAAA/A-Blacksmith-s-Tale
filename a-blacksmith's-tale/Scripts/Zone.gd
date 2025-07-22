class_name Zone extends Node2D

@export var zone_id: int
@export var transitions: Array[TransitionArea]
@export var external_inventories: Array
@export var dialogue_objects: Array

# THIS CODE IS DISGUSTING - AVERT YOUR EYESA
func get_external_inventories() -> Array:
	for child in get_children():
		if child.name == "Objects":
			for c in child.get_children():
				if c.is_in_group("external_inventory"):
					external_inventories.append(c)
	
	return external_inventories

func get_dialogue_objects() -> Array:
	for child in get_children():
		if child.name == "Objects":
			for c in child.get_children():
				if c.is_in_group("dialogue_object"):
					dialogue_objects.append(c)
	return dialogue_objects

func get_npcs() -> Array:
	var npc_characters: Array = []
	for child in get_children():
		if child.name == "Characters":
			for c in child.get_children():
				npc_characters.append(c)
	if npc_characters == []:
		print("No NPC Characters in Zone.")
	return npc_characters
