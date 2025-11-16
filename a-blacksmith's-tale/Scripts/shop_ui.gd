extends Control
class_name ShopUI

const SHOP_SLOT = preload("res://Scenes/ShopSlot.tscn")
@onready var grid: GridContainer = $ShopSection/MarginContainer/ScrollContainer/GridContainer

@onready var shop_section: PanelContainer = $ShopSection
@onready var inventory: InventoryUI = $Inventory

var slow_ramp_active: bool = false
var slow_ramp_item: ItemData = null
var slow_ramp_timer: float = 0.0
var slow_ramp_delay: float = 0.5    # starting delay between purchases (in seconds)
var min_ramp_delay: float = 0.05    # fastest it can get
var ramp_accel: float = 0.03        # how much faster per purchase

@export var shop_slots = [ShopSlot]

@export var cur_shop_data: ShopData

func _process(delta: float) -> void:
	if slow_ramp_active and slow_ramp_item:
		slow_ramp_timer -= delta
		if slow_ramp_timer <= 0:
			# try to buy item
			if not _can_afford(slow_ramp_item):
				stop_slow_ramp()
				return
			
			if not buy_item(slow_ramp_item):
				stop_slow_ramp()
				return

			# ramp up speed
			slow_ramp_delay = max(min_ramp_delay, slow_ramp_delay - ramp_accel)
			slow_ramp_timer = slow_ramp_delay

func set_shop(shop_data: ShopData, inventory_data: InventoryData) -> void:
	cur_shop_data = shop_data
	populate_shop(cur_shop_data)
	inventory.populate_grid(inventory_data, 36, true, false)

func populate_shop(shop_data: ShopData) -> void:
	print("Populate Shop")
	for child in grid.get_children():
		child.queue_free()
	
	shop_slots.clear()   
	
	for index in range(shop_data.items_sold.size()):
		var slot = SHOP_SLOT.instantiate()
		grid.add_child(slot)
		shop_slots.append(slot)
		
		slot.slot_clicked.connect(on_inventory_shop_interact)
		
		slot.set_item_data(shop_data.items_sold[index])

func _set_shop_inventories(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interacted.connect(on_inventory_shop_interact)
	inventory.set_inventory_data(inventory_data)

func on_inventory_shop_interact(item_data: ItemData, button: int) -> void:
	match [button]:
		[MOUSE_BUTTON_LEFT]: # _ means it can be anything
			print("LMB pressed on " + str(item_data.name))
			buy_item(item_data)
		[MOUSE_BUTTON_RIGHT]:
			print("RMB pressed on " + str(item_data.name))
			if slow_ramp_active:
				stop_slow_ramp()
			else: 
				slow_ramp_buy(item_data)

func buy_item(item_data: ItemData) -> bool:
	if not _can_afford(item_data):
		print("Not enough gold (Brokie LOL)")
		return false

	var slot_data = get_item(item_data)
	if not Global.player.inventory.pick_up_slot_data(slot_data):
		return false
	inventory.populate_grid(Global.player.inventory, 36, true, false)

	# subtract player gold
	Global.player_gold -= item_data.buy_price
	print("Bought %s, Gold left: %d" % [item_data.name, Global.player_gold])
	return true

func slow_ramp_buy(item_data: ItemData) -> void:
	if not _can_afford(item_data):
		print("Not enough gold to start ramping.")
		return
	buy_item(item_data) # Initial Buy
	slow_ramp_active = true
	slow_ramp_item = item_data
	slow_ramp_delay = 0.5
	slow_ramp_timer = slow_ramp_delay

func stop_slow_ramp():
	slow_ramp_active = false
	slow_ramp_item = null
	print("Stopped slow ramp buying.")

func get_item(item_data: ItemData) -> ItemStack:
	var slot_data = ItemStack.new()
	slot_data.item_data = item_data
	slot_data.set_quantity(1)
	return slot_data

func _can_afford(item_data: ItemData) -> bool:
	if item_data: 
		return Global.player_gold >= item_data.buy_price
	
	return false
