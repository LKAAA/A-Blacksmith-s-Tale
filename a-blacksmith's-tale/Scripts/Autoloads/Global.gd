extends Node

@export var player: PlayerBase
@export var player_name: String = "Stevie Wonder"
@export var player_shop_name: String = "Bricked Up Smithing"
@export var player_gender: String = "female"
@export var player_race: String = "Human"
@export var active_slot: SlotData
@export var game_paused: bool
signal paused
signal unpaused

var cur_zone_id: int

const MAX_TOOL_EFFICIENCY: int = 10

enum tool_types {
	Pickaxe, 
	Axe, 
	Shovel
	}

# Time

var cur_minute: int
var cur_hour: int
var hour_12: int
var cur_day: String
var cur_season: String
var is_raining: bool = false
var am_pm: String = "AM"

func load_recipes(path: String) -> Array:
	var recipes: Array[RecipeData] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				var loaded_recipe = load(path + file_name)
				recipes.append(loaded_recipe)
			file_name = dir.get_next()
		return recipes
	else:
		printerr("An error occured when trying to access the path.")
		return []

func pause_game() -> void:
	if not game_paused:
		print("Pausing")
		game_paused = true
		paused.emit()
	else:
		print("Already paused")

func unpause_game() -> void:
	if game_paused:
		print("Unpausing")
		game_paused = false
		unpaused.emit()
	else:
		print("Already unpaused")
