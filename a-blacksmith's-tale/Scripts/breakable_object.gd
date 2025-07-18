extends StaticBody2D

const ITEM_PICKUP = preload("res://Scenes/item_pickup.tscn")

@onready var breakable_area: Area2D = $breakable_area

@export var hitpoints: int = 1
@export_enum("Pickaxe", "Axe", "Shovel") var required_tool_type: String = ""
@export_range(1, Global.MAX_TOOL_EFFICIENCY) var required_efficiency: int = 1

#var loot_table: LootTable
@export var item_drop: ItemData

func _ready() -> void:
	breakable_area.hit = Callable(self, "_on_hit")

func _on_hit(active_item: ItemData) -> void:
	if not active_item:
		return
	
	if active_item.type == "Tool":
		var tool: ItemDataTool = active_item
		if not tool.tool_type == required_tool_type:
			print("Not right tool type")
			return
		
		if not tool.tool_efficiency >= required_efficiency:
			print("Not high enough efficiency")
			return
		
		hitpoints -= tool.tool_damage
		print("Hitpoints = " + str(hitpoints))
		
		if hitpoints <= 0:
			print("Fully broke")
			var dropped_item = ITEM_PICKUP.instantiate()
			get_tree().get_root().add_child(dropped_item)
			
			var slot_data = SlotData.new()
			slot_data.item_data = item_drop
			slot_data.quantity = 4
			
			dropped_item.slot_data = slot_data
			
			dropped_item.update_texture()
			dropped_item.position = self.position
			queue_free()
			
			
	else:
		print("Not a tool")
		print(active_item.name)
