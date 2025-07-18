extends StaticBody2D
class_name HarvestableItem

@onready var interact_area: Interactable = $InteractArea
@onready var random_sound_player: RandomSoundPlayer = $RandomSoundPlayer

#var loot_table: LootTable
@export var item_drop: ItemData

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var slot_data = get_item()
	if Global.player.inventory.pick_up_slot_data(slot_data):
			random_sound_player.playSFX(0)
	print("Interact with ")

func get_item() -> SlotData:
	var slot_data = SlotData.new()
	slot_data.item_data = item_drop
	slot_data.set_quantity(5)
	return slot_data

# Wait till sound effect finishes playing to delete
func _on_random_sound_player_finished() -> void:
	queue_free()
