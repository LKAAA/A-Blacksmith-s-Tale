extends StaticBody2D
class_name HarvestableItem

@onready var interact_area: Interactable = $InteractArea
@onready var random_sound_player: RandomSoundPlayer = $RandomSoundPlayer
@export var rand_item: bool = false
@export var loot_table: LootTable

@export var xp_reward: int = 0
@export var skill_type: String = "Foraging"

#var loot_table: LootTable
@export var item_drop: ItemData

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var item_stack
	if rand_item and loot_table:
		item_stack = get_random_item()
	else:
		item_stack = get_item()
	if Global.player.inventory_system.add_item_stack(item_stack):
		random_sound_player.playSFX(0)
		if xp_reward > 0:
			Global.player.level_manager.gain_xp(skill_type, xp_reward)
	print("Interact with ")

func get_item() -> ItemStack:
	var slot_data = ItemStack.new()
	slot_data.item_data = item_drop
	slot_data.set_quantity(5)
	return slot_data

func get_random_item() -> ItemStack:
	var recieved_loot = loot_table.roll_loot()
	var item_stack = ItemStack.new()
	item_stack.item_data = recieved_loot.get(0)
	item_stack.set_quantity(recieved_loot[0])
	return item_stack

# Wait till sound effect finishes playing to delete
func _on_random_sound_player_finished() -> void:
	queue_free()
