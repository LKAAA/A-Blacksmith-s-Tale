extends Node

@export var player: PlayerBase
@export var active_slot: SlotData
@export var game_paused: bool

const MAX_TOOL_EFFICIENCY: int = 10

enum tool_types {
	Pickaxe, 
	Axe, 
	Shovel
	}
