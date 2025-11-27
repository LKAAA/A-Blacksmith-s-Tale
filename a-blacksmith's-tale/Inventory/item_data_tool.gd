extends ItemData
class_name ItemDataTool

@export var tool_type: ItemManager.TOOL_TYPES = ItemManager.TOOL_TYPES.PICKAXE
@export var tool_efficiency: int = 1
@export var tool_damage: int = 1
@export var held_slot: ItemStack = null

func use(target) -> void:
	if Global.can_harvest:
		print("Item Data Harvest")
		target.harvest(tool_type, tool_efficiency, tool_damage)
