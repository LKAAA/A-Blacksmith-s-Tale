extends Resource
class_name LootTable

enum LootMode { WEIGHTED, INDEPENDENT }

@export var entries: Array[LootEntry] = []
@export var rolls: int = 1
@export var mode: LootMode = LootMode.INDEPENDENT

func roll_loot() -> Dictionary:
	var results: Dictionary = {}
	
	for entry in entries: # Auto get this item and take it out of the pool so it doesn't duplicate
		if entry.drop_chance == 100:
			var amount = randi_range(entry.amount_low, entry.amount_high)
			if amount > 0:
				results[entry.item_data] = results.get(entry.item_data, 0) + amount
			entries.remove_at(entries.find(entry))
	
	for i in range(rolls):
		match mode:
			LootMode.WEIGHTED: # Drops a singular type of item with weighted chance
				if entries.is_empty():
					continue
				var chosen_entry = weighted_pick(entries)
				var amount = randi_range(chosen_entry.amount_low, chosen_entry.amount_high)
				if amount > 0:
					results[chosen_entry.item_data] = results.get(chosen_entry.item_data, 0) + amount
			
			LootMode.INDEPENDENT: # Decides whether you drop the item independently of each other item
				for entry in entries:
					if randf() <= entry.drop_chance:
						var amount = randi_range(entry.amount_low, entry.amount_high)
						if amount > 0:
							results[entry.item_data] = results.get(entry.item_data, 0) + amount
	
	return results


func weighted_pick(entry_list: Array[LootEntry]) -> LootEntry:
	var total_weight = 0
	for e in entry_list:
		total_weight += e.weight
	
	var roll = randi_range(1, total_weight)
	var cumulative = 0
	
	for e in entry_list:
		cumulative += e.weight
		if roll <= cumulative:
			return e
	
	return entry_list[0] # fallback
