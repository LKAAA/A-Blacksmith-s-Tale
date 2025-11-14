extends Node

@export var cooling_jobs: Array = []

# Maps item_id -> ItemResource
var items_by_id: Dictionary = {}

# Maps item_file_name (like "oak_log") -> ItemResource
var items_by_name: Dictionary = {}

const ITEMS_FOLDER := "res://Data/Items/" # Folder containing item resources

func _ready() -> void:
	items_by_id.clear()
	items_by_name.clear()
	load_all_items(ITEMS_FOLDER)

func load_all_items(base_path: String) -> void:
	var dir = DirAccess.open(base_path)
	
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var path = base_path + file_name
				var item: ItemData = load(path)
				if item:
					print("Found ", item.name, " ID: ", item.id)
					if items_by_id.has(item.id):
						printerr(item.name, " has the same ID as ", items_by_id[item.id])
					if items_by_id.has(file_name.get_basename()):
						printerr(item.name, " has the same file name as ", items_by_id[item.id])
					
					items_by_id[item.id] = item
					items_by_name[file_name.get_basename()] = item
		for subdir in dir.get_directories():
			print(base_path + subdir + "/")
			load_all_items(base_path + subdir + "/")
	else:
		printerr("Directory for items was not found.")

func get_item_by_id(id: int) -> ItemData:
	if items_by_id.has(id):
		return items_by_id[id]
	push_warning("Item with ID %s not found." % id)
	return null


func get_item_by_name(name_key: String) -> ItemData:
	# Example: "oak_log"
	if items_by_name.has(name_key):
		return items_by_name[name_key]
	push_warning("Item with name '%s' not found." % name_key)
	return null





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
					#h_slot.item_data = TONGS.duplicate()
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
	
