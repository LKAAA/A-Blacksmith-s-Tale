extends Control
class_name ShopUI

const SHOP_SLOT = preload("res://Scenes/ShopSlot.tscn")
@onready var grid: GridContainer = $ShopSection/MarginContainer/ScrollContainer/GridContainer

@onready var shop_section: PanelContainer = $ShopSection
@onready var inventory: InventoryUI = $Inventory

@export var shop_slots = [ShopSlot]

@export var cur_shop_data: ShopData

func set_shop(shop_data: ShopData, inventory_data: InventoryData) -> void:
	cur_shop_data = shop_data
	populate_shop(cur_shop_data)
	inventory.populate_grid(inventory_data)

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

func buy_item(item_data: ItemData) -> void:
	var slot_data = get_item(item_data)
	Global.player.inventory.pick_up_slot_data(slot_data)

func get_item(item_data: ItemData) -> SlotData:
	var slot_data = SlotData.new()
	slot_data.item_data = item_data
	slot_data.set_quantity(1)
	return slot_data
	
