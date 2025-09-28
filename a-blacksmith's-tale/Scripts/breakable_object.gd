extends StaticBody2D

@onready var breakable_area: Area2D = $breakable_area
@onready var loot_component: LootComponent = %Loot_Component
var OAK_STUMP = load("res://Scenes/Objects/BreakableObjects/oak_stump.tscn")

@export var hitpoints: int = 1
@export_enum("Pickaxe", "Axe", "Shovel") var required_tool_type: String = ""
@export_range(1, Global.MAX_TOOL_EFFICIENCY) var required_efficiency: int = 1

@export var xp_reward: int = 0
@export var skill_type: String = "Mining"

@export var loot_table: LootTable

@export var spawn_stump: bool = false

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
		print(self.name)
		print("Hitpoints = " + str(hitpoints))
		
		if hitpoints <= 0:
			if loot_table:
				var recieved_loot = loot_table.roll_loot()
			
				for drop in recieved_loot.keys():
					loot_component.create_pickup(drop, recieved_loot[drop])
			
			if xp_reward > 0:
				Global.player.level_manager.gain_xp(skill_type, xp_reward)
			
			if spawn_stump: 
				var stump = OAK_STUMP.instantiate()
				stump.position = self.position
				get_parent().add_child(stump)
			
			queue_free()
			
	else:
		print("Not a tool")
		print(active_item.name)
