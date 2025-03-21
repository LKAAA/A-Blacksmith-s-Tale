extends ItemData
class_name ItemDataConsumable

@export var heal_gain_value: int
@export var mana_gain_value: int
@export var stamina_gain_value: int

@export var item_to_give: ItemData
@export var item_to_give_quantity: int = 1

func use(target) -> void:
	if heal_gain_value != 0:
		target.health_manager.heal(heal_gain_value)
	if mana_gain_value != 0:
		print("Mana not implemented yet nor confirmed lul")
	if stamina_gain_value != 0:
		target.stats.increase_stamina(stamina_gain_value)
	
	if item_to_give:
		print("Give item")
		target.inventory_data.create_slot_data(item_to_give, item_to_give_quantity)
