extends ItemData
class_name ItemDataEquip

@export var equip_modifiers: Array[Modifier]

# Change to global enum
@export_enum("Head", "Chest", "Feet") var equip_type: int

func equipped(target) -> void:
	print("Equip %s", pretty_name)

func unequipped(target) -> void:
	print("Unequip %s", pretty_name)
