extends Node

@export var cooling_jobs: Array = []

const TONGS = preload("res://Data/Items/Tools/tongs.tres")

func _start_cooling_job(item: ItemData, item_holder: ItemData, inventory: InventoryData) -> void:
	print("Starting item job for item:", item.name)

	var new_job := {
		"id": cooling_jobs.size() + 1,
		"item": item.duplicate(),
		"inventory": inventory,
		"item_holder": item_holder
	}
	cooling_jobs.append(new_job)

func _physics_process(delta: float) -> void:
	for cooling_job in cooling_jobs:
		cooling_job["item"].cur_temp = max(0.0, cooling_job["item"].cur_temp - Global.base_cooling_rate * delta * 50.0) # change to 10
		
		cooled_item(cooling_job)

func cooled_item(cooling_job) -> void:
	if cooling_job["item"].cur_temp <= 0:
			print("The item cooled from a heated state.")
			var slot: SlotData = SlotData.new()
			slot.item_data = cooling_job["item"]
			slot.quantity = 1
			if cooling_job["inventory"].pick_up_slot_data(slot):
				print("Picked up item")
				if cooling_job["item_holder"].id == 17: # If in use tongs
					var item_holder: ItemDataTool = cooling_job["item_holder"]
					var inv: InventoryData = cooling_job["inventory"]
					item_holder.held_slot = null
					var h_slot: SlotData = SlotData.new()
					h_slot.item_data = TONGS.duplicate()
					h_slot.quantity = 1
					var index = inv.get_index_of_item(item_holder)
					
					if not index == -1: 
						inv.remove_single_item(item_holder, index)
						inv.drop_slot_data(h_slot, index)
				cooling_jobs.remove_at(cooling_jobs.find(cooling_job))
			else:
				print("No room")

func quick_cool_item(item_slot: SlotData): 
	print("Quick cool")
	# If item slot has a cooling job
	# set temp to 0
	# call cooled_item
	
