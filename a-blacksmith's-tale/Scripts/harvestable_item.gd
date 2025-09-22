extends StaticBody2D
class_name HarvestableItem

@onready var interact_area: Interactable = $InteractArea
@onready var random_sound_player: RandomSoundPlayer = $RandomSoundPlayer
@export var rand_item: bool = false
@export var loot_table: LootTable

#var loot_table: LootTable
@export var item_drop: ItemData

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var slot_data
	if rand_item and loot_table:
		slot_data = get_random_item()
	else:
		slot_data = get_item()
	if Global.player.inventory.pick_up_slot_data(slot_data):
			random_sound_player.playSFX(0)
	print("Interact with ")

func get_item() -> SlotData:
	var slot_data = SlotData.new()
	slot_data.item_data = item_drop
	slot_data.set_quantity(5)
	return slot_data

func get_random_item() -> SlotData:
	var recieved_loot = loot_table.roll_loot()
	var slot_data = SlotData.new()
	slot_data.item_data = recieved_loot.get(0)
	slot_data.set_quantity(recieved_loot[0])
	return slot_data

# Wait till sound effect finishes playing to delete
func _on_random_sound_player_finished() -> void:
	queue_free()
