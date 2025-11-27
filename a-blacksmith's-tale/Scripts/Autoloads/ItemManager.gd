extends Node

enum ITEM_TYPES {MATERIAL, TOOL, CONSUMABLE, WEAPON, PLACEABLE}
enum WEAPON_TYPES {BOW, ONEHANDEDSWORD, GREATSWORD, AXE}
enum TOOL_TYPES {AXE, PICKAXE, SHOVEL, TONGS}

const MAX_STACK_SIZE: int = 999

# Maps item_id -> ItemResource
var items_by_id: Dictionary = {}
# Maps item_file_name (like "oak_log") -> ItemResource
var items_by_name: Dictionary = {}

const ITEMS_FOLDER := "res://Data/Items/" # Folder containing item resources

func _ready() -> void:
	items_by_id.clear()
	items_by_name.clear()
	load_all_items(ITEMS_FOLDER)

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

func load_all_items(base_path: String) -> void:
	var dir = DirAccess.open(base_path)
	
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var path = base_path + file_name
				var item: ItemData = load(path)
				if item:
					print("Found ", item.pretty_name, " ID: ", item.id)
					if items_by_id.has(item.id):
						printerr(item.pretty_name, " has the same ID as ", items_by_id[item.id])
					if items_by_id.has(file_name.get_basename()):
						printerr(item.pretty_name, " has the same file name as ", items_by_id[item.id])
					
					items_by_id[item.id] = item
					items_by_name[file_name.get_basename()] = item
		for subdir in dir.get_directories():
			print(base_path + subdir + "/")
			load_all_items(base_path + subdir + "/")
	else:
		printerr("Directory for items was not found.")
