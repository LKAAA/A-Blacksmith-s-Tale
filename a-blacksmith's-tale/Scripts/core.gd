class_name Core extends Node2D

const PLAYER = preload("res://Player/player.tscn")
const NPC_CORE = preload("res://Scenes/Objects/npc_core.tscn")

@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var menu_ui: Menu = %Menu_UI
@onready var game_ui: GameUI = %Game_UI
@onready var shop_ui: ShopUI = %ShopUI
@onready var hovering_indicator: TileMapLayer = $"Hovering Indicator"
@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var time_manager: TimeManager = $TimeManager
@onready var timer: Timer = $Timer

var external: bool = false
var cur_zone: String
var cur_transition: int

var current_zone: Zone
var next_zone: Zone
var player: PlayerBase
var active_npcs: Array[NPCCore] = []

var dialogue_cooldown: bool = false

# ----------------------------------------------------------
# Lifecycle
# ----------------------------------------------------------

func _ready() -> void:
	Global.core = self
	load_zone()
	loading_screen.fade_in_finished.connect(fade_in_finished)
	time_manager.time_tick.connect(time_tick_update)
	ScheduleManager._interpret_schedules()
	new_day()

func time_tick_update(day, hour, hour_12, minute, current_weekday, current_season, am_or_pm) -> void:
	game_ui.update_time_label(day, hour, hour_12, minute, current_weekday, current_season, am_or_pm)

func new_day() -> void:
	ScheduleManager._decide_todays_schedules()
	for npc in Progression.NPCS_MET:
		if Progression.NPCS_MET[npc]:
			Progression.NPC_DAYS_SINCE_MET[npc] += 1
			print("Days since met %s is now %s" % [npc, str(Progression.NPC_DAYS_SINCE_MET[npc])])

# ----------------------------------------------------------
# Objects
# ----------------------------------------------------------

func request_break(breakable_object):
	breakable_object._on_hit(game_ui.get_active_item())


# ----------------------------------------------------------
# Dialogue
# ----------------------------------------------------------

func _request_dialogue(object) -> void:
	print("recieved signal")
	if not dialogue_cooldown:
		dialogue_manager._choose_message(object)

func _on_dialogue_manager_finished() -> void:
	timer.start(0.5)
	dialogue_cooldown = true
	Global.unpause_game()
	
	#next_label.visible = true

func _on_dialogue_manager_message_completed() -> void:
	#next_label.visible = false
	pass # Replace with function body.

func _on_dialogue_manager_message_requested() -> void:
	#next_label.visible = false
	pass # Replace with function body.

# ----------------------------------------------------------
# Inventory
# ----------------------------------------------------------

func escape_ui() -> void:
	if shop_ui.visible:
		hide_shop_ui()
	else:
		toggle_inventory_interface()

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	if shop_ui.visible:
		return
	
	menu_ui.visible = !menu_ui.visible
	
	if menu_ui.visible:
		game_ui.hide()
		Global.pause_game()
	else:
		game_ui.show()
		Global.unpause_game()
	
	menu_ui._update_player_inventory(player.inventory)
	menu_ui.player_inventory.visible = true
	
	if external_inventory_owner and menu_ui.visible:
		menu_ui._set_external_inventory(external_inventory_owner)
		menu_ui.external_inventory.visible = true
		menu_ui.external = true
		external = true
	else:
		menu_ui.clear_external_inventory()
		menu_ui.external_inventory.visible = false
		menu_ui.external = false
		external = false

func load_external_inventories(zone: Zone) -> void:
	for node in zone.get_external_inventories():
		node.toggle_inventory.connect(toggle_inventory_interface)
		print("Loaded " + node.name)

func unload_external_inventories(zone: Zone) -> void:
	for node in zone.get_external_inventories():
		if node.is_connected("toggle_inventory", toggle_inventory_interface):
			node.toggle_inventory.disconnect(toggle_inventory_interface)
			print("Disconnected " + node.name)

# ----------------------------------------------------------
# Shop
# ----------------------------------------------------------

func hide_shop_ui() -> void:
	if shop_ui.visible:
		shop_ui.hide()
		game_ui.show()
		Global.unpause_game()
		Global.shop_active = false

func toggle_shop_ui(shop_data: ShopData) -> void:
	shop_ui.visible = !shop_ui.visible
	
	if shop_ui.visible:
		game_ui.hide()
		Global.pause_game()
		Global.shop_active = true
	else:
		game_ui.show()
		Global.unpause_game()
		Global.shop_active = false
	
	shop_ui.set_shop(shop_data, player.inventory)

func load_shops(zone: Zone) -> void:
	for node in zone.get_shops():
		node.toggle_shop.connect(toggle_shop_ui)
		print("Loaded " + node.name)

func unload_shops(zone: Zone) -> void:
	for node in zone.get_shops():
		if node.is_connected("toggle_shop", toggle_shop_ui):
			node.toggle_shop.disconnect(toggle_shop_ui)
			print("Disconnected " + node.name)

# ----------------------------------------------------------
# Zones
# ----------------------------------------------------------

# @param path is the path of the scene to transition to
# @param transition is the number in the transitions array on each zone to teleport the player to
func load_zone(zone: String = "", transition: int = 99) -> void:
	if !current_zone: # irst time setup
		_setup_first_zone()
	else:
		cur_zone = zone
		cur_transition = transition
		loading_screen.fade_in()

func fade_in_finished() -> void:
	_load_next_zone()
	loading_screen.fade_out()

# ----------------------------------------------------------
# Helpers
# ----------------------------------------------------------

func _setup_first_zone() -> void:
	print("Loading first zone")
	current_zone = load("res://TEMP/TestZone1.tscn").instantiate()
	add_child(current_zone)
	
	_connect_zone_signals(current_zone)
	
	player = PLAYER.instantiate()
	current_zone.add_child(player)
	player.position = Vector2(300,80)
	player.inventory.inventory_slots.resize(36)
	
	player.open_inventory.connect(toggle_inventory_interface)
	player.escape_ui.connect(escape_ui)
	player.use.connect(game_ui.use_slot)
	player.request_break.connect(request_break)
	
	Global.player = player
	
	menu_ui._set_player_inventory(player.inventory)
	game_ui._set_hotbar_inventory(player.inventory)
	
	load_external_inventories(current_zone)
	load_shops(current_zone)
	load_npcs(current_zone.zone_id)
	
	_connect_dialogues(current_zone)
	
	update_grid(current_zone)
	
	Global.cur_zone_id = current_zone.zone_id

func _load_next_zone() -> void:
	next_zone = load(cur_zone).instantiate()
	call_deferred("add_child", next_zone)
	
	if player: 
		player.reparent(next_zone)
		player.position = next_zone.transitions[cur_transition].position if cur_transition != 99 else Vector2.ZERO
	
	if current_zone: 
		unload_external_inventories(current_zone)
		unload_shops(current_zone)
		current_zone.queue_free()
	
	current_zone = next_zone
	next_zone = null
	
	_connect_zone_signals(current_zone)
	load_external_inventories(current_zone)
	load_shops(current_zone)
	load_npcs(current_zone.zone_id)
	_connect_dialogues(current_zone)
	
	Global.cur_zone_id = current_zone.zone_id
	
	update_grid(current_zone)
	
	cur_zone = ""
	cur_transition = 0

func load_npcs(current_zone_id) -> void:
	for npc in current_zone.get_npcs():
		npc.queue_free()
		
	# Ask ScheduleManager which NPCs belong here now
	var cur_time = Global.cur_hour * 100 # e.g., 830
	var npcs = ScheduleManager.get_zone_npcs(current_zone.zone_id, cur_time)
	
	print("At load NPCS the we have %s" % npcs)
	
	for npc_name in npcs.keys():
		var event = npcs[npc_name]["event"]
		var npc: NPCCore = NPC_CORE.instantiate()
		npc.set_schedule(npcs[npc_name]["schedule"])
		npc.char_name = npc_name
		current_zone.add_child(npc)
		npc.position = event["pos"]
		npc.facing = event["facing"]
		print("Spawned %s at %s" % [npc_name, str(event["pos"])])

func update_grid(current_zone: Zone) -> void:
	if current_zone.tilemap_base and current_zone.tilemap_obstacles:
		Grid.update_tilemaps(current_zone.tilemap_base, current_zone.tilemap_obstacles)
	else:
		printerr("You forgot to add the tilemaps for the grid")
	
	var obstacles = current_zone.get_obstacles()
	print("Obstacles: ", obstacles)
	for obstacle in obstacles:
		if "size" in obstacle:
			Grid.set_object_walkable(obstacle.position, obstacle.size, false)
		else:
			Grid.set_object_walkable(obstacle.position, [1, 1], false)
		
		print("Obstacle was set")
	
	for tile in Grid.walk_grid:
		current_zone.tilemap_base.set_cell(tile, 1, Vector2i(13, 2))
	
	Grid.update_dynamic_objects_into_grid()

func _connect_zone_signals(zone: Zone) -> void:
	for t in zone.transitions:
		t.transition_entered.connect(load_zone)

func _connect_dialogues(zone: Zone) -> void:
	for child in zone.get_dialogue_objects():
		if not child.request_dialogue.is_connected(_request_dialogue):
			child.request_dialogue.connect(_request_dialogue)


func _on_timer_timeout() -> void:
	dialogue_cooldown = false

func get_mouse_pos() -> Vector2:
	return get_global_mouse_position()
