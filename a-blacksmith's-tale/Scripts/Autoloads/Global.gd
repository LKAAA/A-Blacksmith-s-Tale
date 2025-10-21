extends Node

const TILE_SIZE: int = 16

@export var core: Core

@export var player: PlayerBase
@export var player_name: String = "Stevie Wonder"
@export var player_shop_name: String = "Bricked Up Smithing"
@export var player_gender: String = "m"
@export var player_race: String = "Human"
@export var tool_usage_stamina: float = 1
@export var tool_cooldown: int = 0.1
@export var active_slot: SlotData
@export var active_slot_index: int = 0
@export var game_paused: bool
@export var dialogue_active: bool = false
@export var shop_active: bool = false
@export var forge_ui_active: bool = false
@export var build_range: int = 100
signal paused
signal unpaused

@export var base_heating_rate: float = 10 #0.5    # how quickly temp rises per second normally (deg/sec)
@export var base_cooling_rate: float = 0.2    # how quickly temp falls per second when no fuel (deg/sec)


@export var player_gold: int = 9999999999

@export var cur_zone_id: int

const MAX_TOOL_EFFICIENCY: int = 10

enum tool_types {
	Pickaxe, 
	Axe, 
	Shovel
	}

@export var INGAME_SPEED: float = 1.0 # float = in game minutes to irl seconds (INGAME_SPEED = 10, every 1 second = 10 minutes)
var cur_minute: int
var cur_hour: int
var hour_12: int
var cur_day: String
var cur_season: String
var is_raining: bool = false
var am_pm: String = "AM"
signal time_changed(new_time: int)

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

func get_mouse_pos() -> Vector2:
	return core.get_mouse_pos()
