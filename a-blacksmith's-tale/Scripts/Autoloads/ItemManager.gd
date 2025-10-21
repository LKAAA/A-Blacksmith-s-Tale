extends Node

@export var cooling_jobs: Array = []

func _start_cooling_job(item: ItemData, temperature: float, inventory: InventoryData) -> void:
	print("Starting item job for item:", item.name)

	var new_job := {
		"id": cooling_jobs.size() + 1,
		"item": item,
		"cur_temperature": float(temperature),
		"inventory": inventory
	}
	cooling_jobs.append(new_job)

func _physics_process(delta: float) -> void:
	for cooling_job in cooling_jobs:
		cooling_job["cur_temperature"] = max(0.0, cooling_job["cur_temperature"] - Global.base_cooling_rate * delta * 50.0) # change to 10
		
		if cooling_job["cur_temperature"] <= 0:
			print("The item cooled from a heated state.")
			var slot: SlotData = SlotData.new()
			slot.item_data = cooling_job["item"]
			slot.quantity = 1
			if cooling_job["inventory"].pick_up_slot_data(slot):
				print("Picked up item")
				cooling_jobs.remove_at(cooling_jobs.find(cooling_job))
			else:
				print("No room")
