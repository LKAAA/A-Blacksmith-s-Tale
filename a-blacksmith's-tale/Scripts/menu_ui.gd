extends Control

@onready var grabbed_slot: Slot = %GrabbedSlot
@onready var inventory_ui: InventoryUI = %InventoryUI
@export var grabbed_slot_padding = -5

var grabbed_slot_data: SlotData = null

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	grabbed_slot.position = Vector2(mouse_pos.x + grabbed_slot_padding, mouse_pos.y + grabbed_slot_padding)

func _set_player_inventory(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interacted.connect(on_inventory_interact)
	inventory_ui.set_inventory_data(inventory_data)

func _update_player_inventory(inventory_data: InventoryData) -> void:
	inventory_ui.populate_grid(inventory_data)

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			#print("Has nothing, grab all slot data")
			grabbed_slot_data = inventory_data.grab_slot_data(index)
			Popups.HideItemPopup()
		[_, MOUSE_BUTTON_LEFT]: # _ means it can be anything
			#print("Has something, drop all of slot data")
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			#print("Has nothing, grab single slot data")
			grabbed_slot_data = inventory_data.grab_new_single_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]: # _ means it can be anything
			#print("Has something, grab another single slot data")
			grabbed_slot_data = inventory_data.grab_single_slot_data(grabbed_slot_data, index)
	
	update_grabbed_slot(grabbed_slot_data)

func update_grabbed_slot(slot_data: SlotData):
	grabbed_slot.set_slot_data(slot_data)
	if grabbed_slot.slot_data:
		Popups.grabbed_item = true
	else:
		Popups.grabbed_item = false
