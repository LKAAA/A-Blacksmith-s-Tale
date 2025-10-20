extends ItemData
class_name ItemDataTool

@export_enum("Pickaxe", "Axe", "Shovel", "Tongs") var tool_type: String
@export var tool_efficiency: int = 1
@export var tool_damage: int = 1
@export var held_slot: SlotData = null

func use(target) -> void:
	if Global.can_harvest:
		print("Item Data Harvest")
		target.harvest(tool_type, tool_efficiency, tool_damage)
