class_name Core extends Node2D

const PLAYER = preload("res://Player/player.tscn")

@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var menu_ui: Menu = %Menu_UI

var external: bool = false

var cur_zone: String
var cur_transition: int

var current_zone: Zone
var next_zone: Zone
var player: PlayerBase

func _ready() -> void:
	load_zone()
	loading_screen.fade_in_finished.connect(fade_in_finished)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	menu_ui.visible = !menu_ui.visible
	
	#if inventory_interface.visible:
		#hot_bar_inventory.hide()
	#else:
		#hot_bar_inventory.show()
	menu_ui._update_player_inventory(player.inventory)
	menu_ui.player_inventory.visible = true
	
	if external_inventory_owner and menu_ui.visible:
		menu_ui._set_external_inventory(external_inventory_owner)
		menu_ui.external_inventory.visible = true
		external = true
	else:
		menu_ui.clear_external_inventory()
		menu_ui.external_inventory.visible = false
		external = false

func load_external_inventories() -> void:
	for node in get_tree().get_nodes_in_group("external_inventory"):
		if node.is_inside_tree():
			node.toggle_inventory.connect(toggle_inventory_interface)
			print("Loaded " + node.name)

func unload_external_inventories() -> void:
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.disconnect(toggle_inventory_interface)
		print("Disconnected " + node.name)

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
		player.open_inventory.connect(toggle_inventory_interface)
		menu_ui._set_player_inventory(player.inventory)
		load_external_inventories()
	
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
		unload_external_inventories()
		current_zone.queue_free()

	current_zone = next_zone
	next_zone = null
	
	for t in current_zone.transitions:
		t.transition_entered.connect(load_zone)
	
	load_external_inventories()
	
	cur_zone = ""
	cur_transition = 0
	
	loading_screen.fade_out()
