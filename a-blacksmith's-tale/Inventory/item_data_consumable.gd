extends ItemData
class_name ItemDataConsumable

@export var heal_value: int
@export var mana_value: int
@export var stamina_value: int

@export var item_to_give_id: int = -1
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
	
	if item_to_give_id != -1:
		print("Give item")
		target.inventory_system.add_item_data(ItemManager.get_item_by_id(item_to_give_id), item_to_give_quantity)
	
	target.inventory_system.remove_single_item(self, Global.active_slot_index)
