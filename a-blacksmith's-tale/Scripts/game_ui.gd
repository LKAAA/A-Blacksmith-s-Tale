class_name GameUI extends Control

@onready var hotbar: InventoryUI = %Hotbar

var player_inventory:InventoryData

var active_slot: int = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_scroll_up"):
		active_slot = wrapi(active_slot - 1, 0, 12)  # Wraps between 0 and 11
		print(active_slot)

	if Input.is_action_just_pressed("ui_scroll_down"):
		active_slot = wrapi(active_slot + 1, 0, 12)
		print(active_slot)

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return

	# Dictionary for direct slot mapping
	var key_to_slot = {
		KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3,
		KEY_5: 4, KEY_6: 5, KEY_7: 6, KEY_8: 7, 
		KEY_9: 8, KEY_0: 9, KEY_MINUS: 10, KEY_EQUAL: 11
	}
	
	if event.keycode in key_to_slot:
		active_slot = key_to_slot[event.keycode]
		print(active_slot)

func _set_hotbar_inventory(inventory_data: InventoryData) -> void:
	hotbar.set_inventory_data(inventory_data, 12, false)
	player_inventory = inventory_data

func use_slot() -> void:
	var active_slot_data = player_inventory.inventory_slots[active_slot]
	if active_slot_data:
		print("Using " + active_slot_data.item_data.name)
	else:
		print("No item in slot " + str(active_slot))
