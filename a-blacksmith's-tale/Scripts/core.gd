class_name Core extends Node2D

const PLAYER = preload("res://Player/player.tscn")

@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var menu_ui: Menu = %Menu_UI
@onready var game_ui: GameUI = %Game_UI
@onready var hovering_indicator: TileMapLayer = $"Hovering Indicator"
@onready var dialogue_manager: DialogueManager = $DialogueManager


var external: bool = false

var cur_zone: String
var cur_transition: int

var current_zone: Zone
var next_zone: Zone
var player: PlayerBase

func _ready() -> void:
	load_zone()
	loading_screen.fade_in_finished.connect(fade_in_finished)

#region objects

func request_break(breakable_object):
	breakable_object._on_hit(game_ui.get_active_item())

#endregion

#region Dialogue System

func _request_dialogue() -> void:
	print("recieved signal")
	dialogue_manager.show_messages(["Hello I am a sign.", "I am still a sign", "I promise I won't change.", "[rainbow]Holy fuck I'm gay now[/rainbow]", "[rainbow]GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY GAY[/rainbow]"])

func _on_dialogue_manager_finished() -> void:
	#next_label.visible = true
	pass

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
		
		for child:DialogueInteraction in current_zone.get_dialogue_objects():
			if not child.request_dialogue.is_connected(_request_dialogue):
				child.request_dialogue.connect(_request_dialogue)
	
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
	
	for child: DialogueInteraction in current_zone.get_dialogue_objects():
		if not child.request_dialogue.is_connected(_request_dialogue):
				child.request_dialogue.connect(_request_dialogue)
	
	cur_zone = ""
	cur_transition = 0
	
	loading_screen.fade_out()

#endregion
