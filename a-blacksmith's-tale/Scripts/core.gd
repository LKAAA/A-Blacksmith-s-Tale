class_name Core extends Node2D

const PLAYER = preload("res://Player/player.tscn")

@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var menu_ui: Menu = %Menu_UI
@onready var game_ui: GameUI = %Game_UI
@onready var hovering_indicator: TileMapLayer = $"Hovering Indicator"
@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var schedule_manager: ScheduleManager = $ScheduleManager
@onready var time_manager: TimeManager = $TimeManager


var external: bool = false

var cur_zone: String
var cur_transition: int

var current_zone: Zone
var next_zone: Zone
var player: PlayerBase

func _ready() -> void:
	load_zone()
	loading_screen.fade_in_finished.connect(fade_in_finished)
	time_manager.time_tick.connect(time_passed)
	schedule_manager._interpret_schedules()
	new_day()
	

func time_passed(_day: int, _hour: int, _hour_12: int, _minute: int, _cur_weekday: String, _cur_season: String, _am_pm: String) -> void:
	pass
	#schedule_manager.do_something()

func new_day() -> void:
	schedule_manager._decide_todays_schedules()
	for char in Progression.NPCS_MET:
		if Progression.NPCS_MET[char] == true:
			Progression.NPC_DAYS_SINCE_MET[char] += 1
			print("Days since met " + char + " is now " + str(Progression.NPC_DAYS_SINCE_MET[char]))

#region objects

func request_break(breakable_object):
	breakable_object._on_hit(game_ui.get_active_item())

#endregion

#region Dialogue System

func _request_dialogue(object) -> void:
	print("recieved signal")
	dialogue_manager._choose_message(object)

func _on_dialogue_manager_finished() -> void:
	Global.game_paused = false
	#next_label.visible = true

func _on_dialogue_manager_message_completed() -> void:
	#next_label.visible = false
	pass # Replace with function body.


func _on_dialogue_manager_message_requested() -> void:
	#next_label.visible = false
	pass # Replace with function body.

#endregion

#region Inventory

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	menu_ui.visible = !menu_ui.visible
	
	if menu_ui.visible:
		game_ui.hide()
		Global.game_paused = true
	else:
		game_ui.show()
		Global.game_paused = false
	
	menu_ui._update_player_inventory(player.inventory)
	menu_ui.player_inventory.visible = true
	
	if external_inventory_owner and menu_ui.visible:
		menu_ui._set_external_inventory(external_inventory_owner)
		menu_ui.external_inventory.visible = true
		menu_ui.external = true
		external = true
		menu_ui.player_inventory.position = Vector2(150,180)
	else:
		menu_ui.clear_external_inventory()
		menu_ui.external_inventory.visible = false
		menu_ui.external = false
		external = false
		menu_ui.player_inventory.position = Vector2(150,141)

func load_external_inventories(zone: Zone) -> void:
	var external_inventories: Array = zone.get_external_inventories()
	for node in external_inventories:
		node.toggle_inventory.connect(toggle_inventory_interface)
		print("Loaded " + node.name)

func unload_external_inventories(zone: Zone) -> void:
	var external_inventories: Array = zone.get_external_inventories()
	for node in external_inventories:
		if node.is_connected("toggle_inventory", toggle_inventory_interface):
			node.toggle_inventory.disconnect(toggle_inventory_interface)
			print("Disconnected " + node.name)

#endregion

#region loading zones

# @param path is the path of the scene to transition to
# @param transition is the number in the transitions array on each zone to teleport the player to
func load_zone(zone: String = "", transition: int = 99) -> void:
	# If there is no zone already (This is the first zone spawned in) - Do first time set up
	if !current_zone: # If there is no zone already
		print("Loading default / First zone")
		current_zone = load("res://TEMP/TestZone1.tscn").instantiate()
		add_child(current_zone)
		
		for t in current_zone.transitions:
			t.transition_entered.connect(load_zone)
		
		player = PLAYER.instantiate()
		current_zone.add_child(player)
		player.position = Vector2(300,80)
		player.inventory.inventory_slots.resize(36)
		player.open_inventory.connect(toggle_inventory_interface)
		player.use.connect(game_ui.use_slot)
		player.request_break.connect(request_break)
		menu_ui._set_player_inventory(player.inventory)
		game_ui._set_hotbar_inventory(player.inventory)
		load_external_inventories(current_zone)
		Global.player = player
		
		for child in current_zone.get_dialogue_objects():
			if not child.request_dialogue.is_connected(_request_dialogue):
				child.request_dialogue.connect(_request_dialogue)
		
		for child: NPCCore in current_zone.get_npcs():
			print("Set each npc to the position they should be at rn")
		
		Global.cur_zone_id = current_zone.zone_id
	
	# If there is already a zone set up some variables and start the loading scren fade_in  animation
	else:
		print("Loading " + zone)
		cur_zone = zone
		cur_transition = transition
		loading_screen.fade_in()

# Once the loading screen's signal emits when the fade in animation is finished, we execute the loading in
# Before finally playing the fade out
# This basically fades to black, loads the next scene, then fades back into the gameplay
func fade_in_finished() -> void:
	# If there is a zone
	
	next_zone = load(cur_zone).instantiate()
	call_deferred("add_child", next_zone)

	if player:
		player.reparent(next_zone)
		if cur_transition != 99:
			player.position = next_zone.transitions[cur_transition].position
		else:
			player.position = Vector2(0,0)
	
	if current_zone:
		unload_external_inventories(current_zone)
		current_zone.queue_free()

	current_zone = next_zone
	next_zone = null
	
	for t in current_zone.transitions:
		t.transition_entered.connect(load_zone)
	
	load_external_inventories(current_zone)
	
	for child in current_zone.get_dialogue_objects():
		if not child.request_dialogue.is_connected(_request_dialogue):
			child.request_dialogue.connect(_request_dialogue)
	
	for child: NPCCore in current_zone.get_npcs():
			print("Set each npc to the position they should be at rn")
	
	Global.cur_zone_id = current_zone.zone_id
	
	cur_zone = ""
	cur_transition = 0
	
	loading_screen.fade_out()

#endregion
