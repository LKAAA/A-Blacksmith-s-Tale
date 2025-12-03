class_name GameUI extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var health_bar_text: RichTextLabel = %HealthBarText
@onready var stamina_bar_text: RichTextLabel = %StaminaBarText
@onready var time_label: RichTextLabel = %TimeLabel
@onready var hotbar_grid: HotbarGrid = %hotbar_grid

const OAK_STUMP = preload("res://Scenes/Objects/BreakableObjects/oak_stump.tscn")

var active_slot: int = 0

func _process(_delta: float) -> void:
	update_bars()
	
	if not Global.game_paused: 
		if Input.is_action_just_pressed("scroll_up"):
			active_slot = wrapi(active_slot - 1, 0, 12)  # Wraps between 0 and 11
			set_active_slot()
			print(active_slot)

		if Input.is_action_just_pressed("scroll_down"):
			active_slot = wrapi(active_slot + 1, 0, 12)
			set_active_slot()
			print(active_slot)

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed() or Global.game_paused:
		return

	# Dictionary for direct slot mapping
	var key_to_slot = {
		KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3,
		KEY_5: 4, KEY_6: 5, KEY_7: 6, KEY_8: 7, 
		KEY_9: 8, KEY_0: 9, KEY_MINUS: 10, KEY_EQUAL: 11
	}
	
	if event.keycode in key_to_slot:
		active_slot = key_to_slot[event.keycode]
		set_active_slot()
		print(active_slot)

func _set_hotbar_inventory() -> void:
	hotbar_grid.set_inventory(Global.player.inventory_system)
	#hotbar.size = hotbar.get_minimum_size()

func set_active_slot() -> void:
	var active_item_stack = Global.player.inventory_system.inventory[active_slot]
	Global.active_slot_stack = active_item_stack
	Global.active_slot_index = active_slot
	if active_item_stack:
		print(active_item_stack.item_data.pretty_name)

func get_active_item() -> ItemData:
	if Global.player.inventory_system.inventory[active_slot]:
		return Global.player.inventory_system.inventory[active_slot].item_data
	return null

func use_slot() -> void:
	var active_item_stack = Global.player.inventory_system.inventory[active_slot]
	if active_item_stack:
		match active_item_stack.item_data.type:
			ItemManager.ITEM_TYPES.CONSUMABLE:
				active_item_stack.item_data.use(Global.player)
			ItemManager.ITEM_TYPES.TOOL:
				Global.player.execute_breakable()
			ItemManager.ITEM_TYPES.PLACEABLE:
				active_item_stack.item_data.place(Global.get_mouse_pos())
				
		print("Using " + active_item_stack.item_data.pretty_name)
	else:
		print("No item in slot " + str(active_slot))

func update_bars() -> void:
	if not Global.player: 
		return
	var health_stat: Stat = Global.player.stats_manager.get_stat("health")
	var stamina_stat: Stat = Global.player.stats_manager.get_stat("stamina")
	
	health_bar.max_value = health_stat.base
	stamina_bar.max_value = stamina_stat.base
	
	health_bar.value = health_stat.current
	stamina_bar.value = stamina_stat.current
	
	health_bar_text.text = "%d/%d" % [health_stat.current, health_stat.base]
	stamina_bar_text.text = "%d/%d" % [stamina_stat.current, stamina_stat.base]

func update_time_label(day, _hour, hour_12, minute, current_weekday, current_season, am_or_pm) -> void:
	time_label.text = "%s of %s\n%s\n%02d:%02d %s" % [day, current_season, current_weekday, hour_12, minute, am_or_pm]
