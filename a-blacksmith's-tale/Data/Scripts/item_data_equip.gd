extends ItemData
class_name ItemDataEquip

@export var equip_modifiers: Array[Modifier]

@export_enum("Head", "Chest", "Feet") var equip_type: int

func equipped(target) -> void:
	print("Equip %s", name)

func unequipped(target) -> void:
	print("Unequip %s", name)
