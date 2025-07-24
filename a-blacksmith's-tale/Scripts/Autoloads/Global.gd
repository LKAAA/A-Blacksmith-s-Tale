extends Node

@export var player: PlayerBase
@export var player_name: String = "Stevie Wonder"
@export var player_shop_name: String = "Bricked Up Smithing"
@export var player_gender: String = "female"
@export var player_race: String = "Human"
@export var active_slot: SlotData
@export var game_paused: bool

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
