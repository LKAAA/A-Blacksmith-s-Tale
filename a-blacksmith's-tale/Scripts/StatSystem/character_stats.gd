extends Node
class_name CharacterStats

@export var stat_list: Array[Stat] = []
var stats: Dictionary = {}

signal death
signal fully_tired

func _ready() -> void:
	# Duplicate the stat list so that it is individual per character and not shared
	for stat in stat_list:
		var new_stat: Stat = stat.duplicate(true)
		stats[stat.name.to_lower()] = new_stat

func get_stat(stat_name: String) -> Stat:
	var stat_n = stat_name.to_lower()
	if stats[stat_n]: 
		return stats[stat_n]
	else:
		printerr("Stat does not exist on this object")
		return null

func increase_base(stat_name: String, amount: float) -> void:
	var stat_n = stat_name.to_lower()
	if not stats.get(stat_n):
		print("Error: '%s' not found in stats." % stat_n)
		return
	var stat: Stat = stats[stat_n]
	stat.base += amount
	stat.modified_base = calculate_modified_stat(stat.base, stat.modifiers)

func raise_current(stat_name: String, amount: float) -> void:
	var stat_n = stat_name.to_lower()
	if not stats.get(stat_n):
		print("Error: '%s' not found in stats." % stat_n)
		return
	var stat: Stat = stats[stat_n]
	if stat.current == null: return
	stat.current += amount
	if stat.current > stat.base:
		stat.current = stat.base
	print("%s at %d" % [stat_n, stat.current])

func reduce_current(stat_name: String, amount: float) -> void:
	var stat_n = stat_name.to_lower()
	if not stats.get(stat_n):
		print("Error: '%s' not found in stats." % stat_n)
		return
	var stat: Stat = stats[stat_n]
	if stat.current == null: return
	stat.current -= abs(amount)
	
	if stat.current <= 0:
		print("%s at 0" % stat_n)
		if stat.name == "health":
			death.emit()
		if stat.name == "stamina":
			fully_tired.emit()
	print("%s at %d" % [stat_n, stat.current])

func calculate_modified_stat(base_value: float, modifiers: Array[Modifier] = []) -> float:
	if modifiers.is_empty(): return base_value
	
	var flat_amount = 0
	var percentage_modifier = 1.0
	
	for modifier: Modifier in modifiers:
		if modifier.type == "FLAT":
			flat_amount += modifier.amount
		elif modifier.type == "PERCENTAGE":
			percentage_modifier += modifier.amount
	
	return (base_value + flat_amount) * percentage_modifier # percentage on top of flat amount.

func _process(delta: float) -> void:
	for stat in stat_list:
		if stat.modifiers:
			stat.modifiers = calculate_modifier_timers_for_stat(stat.modifiers, delta)
			stat.modified = calculate_modified_stat(stat.base, stat.modifiers)

func calculate_modifier_timers_for_stat(modifier_array: Array[Modifier], delta: float) -> Array[Modifier]:
	var final_array: Array[Modifier] = modifier_array.duplicate()
	for modifier_index in range(final_array.size() - 1, -1, -1):
		var mod: Modifier = final_array[modifier_index]
		if mod.starting_duration == -1:
			continue
		mod.remaining_duration -= delta
		if mod.remaining_duration <= 0:
			final_array.remove_at(modifier_index)
	
	return final_array
