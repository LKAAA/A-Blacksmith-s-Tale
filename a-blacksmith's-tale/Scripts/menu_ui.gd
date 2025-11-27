class_name Menu extends Control

@onready var grabbed_slot: InventorySlot = %GrabbedSlot
@export var grabbed_slot_padding = -5

@onready var player_inventory: InventoryGrid = %PlayerInventory
@onready var external_inventory: InventoryGrid = %ExternalInventory
@onready var forge_ui: ForgeUI = %Forge_UI

var external = false
var external_inv_system: InventorySystem = null
var grabbed_item_stack: ItemStack = null
var external_inventory_owner

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	grabbed_slot.position = Vector2(mouse_pos.x + grabbed_slot_padding, mouse_pos.y + grabbed_slot_padding)

func _set_player_inventory(inventory_system: InventorySystem) -> void:
	inventory_system.inventory_interacted.connect(on_inventory_interact)
	player_inventory.set_inventory(inventory_system)

func _update_player_inventory(inventory_system: InventorySystem) -> void:
	player_inventory.populate_grid(inventory_system)

func _set_external_inventory(_external_inventory) -> void:
	external_inventory_owner = _external_inventory
	for child in external_inventory_owner.get_children():
		if child is InventorySystem:
			external_inv_system = child
	
	if not external_inv_system: 
		printerr("No inventory system found on this object.")
		return 
	
	external_inv_system.inventory_interacted.connect(on_inventory_interact)
	external_inventory.set_inventory(external_inv_system)

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_system = external_inv_system
		
		inventory_system.inventory_interacted.disconnect(on_inventory_interact)
		external_inventory.clear_inventory(inventory_system)
		
		external_inv_system = null
		external_inventory_owner = null

func on_inventory_interact(inventory_system: InventorySystem, index: int, button: int) -> void:
	print("Inventory Interacted")
	if external == true:
		if Input.is_key_pressed(KEY_SHIFT) && button == MOUSE_BUTTON_LEFT:
			print("SHIFT CLICK THAT MO FO")
			if inventory_system == external_inv_system:
				inventory_system.quick_move_stack(index, ItemManager.player_inventory_system)
			else:
				inventory_system.quick_move_stack(index, external_inv_system)
			
			return
	
	match [grabbed_item_stack, button]:
		[null, MOUSE_BUTTON_LEFT]:
			print("Has nothing, grab all slot data")
			grabbed_item_stack = inventory_system.grab_item_stack(index)
			Popups.hide_item_popup()
		[_, MOUSE_BUTTON_LEFT]: # _ means it can be anything
			print("Has something, drop all of slot data")
			grabbed_item_stack = inventory_system.drop_item_stack(grabbed_item_stack, index)
		[null, MOUSE_BUTTON_RIGHT]:
			print("Has nothing, grab single slot data")
			grabbed_item_stack = inventory_system.grab_new_single_item_stack(index)
		[_, MOUSE_BUTTON_RIGHT]: # _ means it can be anything
			print("Has something, grab another single slot data")
			grabbed_item_stack = inventory_system.grab_single_item_stack(grabbed_item_stack, index)
	
	update_grabbed_slot(grabbed_item_stack)

func update_grabbed_slot(item_stack: ItemStack):
	if item_stack:
		print("Yes")
		grabbed_slot.set_item_stack(item_stack)
	else:
		print("nooo")
		grabbed_slot.set_item_stack(null)
	if grabbed_slot.item_stack:
		Popups.grabbed_slot = true
	else:
		Popups.grabbed_slot = false

#func _set_forge_inventory(inventory_data: InventoryData, cur_forge: Forge) -> void:
	#forge_ui.set_ui(inventory_data, cur_forge)
	#if not forge_ui.cur_forge.fuel_inventory.inventory_interacted.is_connected(on_inventory_interact):
		#forge_ui.cur_forge.fuel_inventory.inventory_interacted.connect(on_inventory_interact)
		#forge_ui.cur_forge.smeltable_inventory.inventory_interacted.connect(on_inventory_interact)
