extends ItemData
class_name ItemDataConsumable

@export var heal_value: int
@export var mana_value: int
@export var stamina_value: int

@export var item_to_give: ItemData
@export var item_to_give_quantity: int = 1

func use(target: PlayerBase) -> void:
	print("We are here")
	if heal_value != 0:
		if heal_value < 0:
			target.stats_manager.reduce_current("health", heal_value)
		else:
			target.stats_manager.raise_current("health", heal_value)
	if mana_value != 0:
		print("Mana not implemented yet nor confirmed lul")
	if stamina_value != 0:
		if stamina_value < 0:
			target.stats_manager.reduce_current("stamina", stamina_value)
		else:
			target.stats_manager.raise_current("stamina", stamina_value)
	
	if item_to_give:
		print("Give item")
		var slot_data: SlotData = SlotData.new()
		slot_data.item_data = item_to_give
		slot_data.set_quantity(item_to_give_quantity)
		target.inventory.pick_up_slot_data(slot_data)
	
	target.inventory.remove_single_item(self, Global.active_slot_index)
