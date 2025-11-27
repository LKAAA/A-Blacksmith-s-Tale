extends Panel
class_name ShopSlot

signal slot_clicked(item_data: ItemStack, button: int)
@onready var item_sprite: TextureRect = $MarginContainer/HBoxContainer/ItemSprite
@onready var item_name_label: RichTextLabel = $MarginContainer/HBoxContainer/ItemNameText
@onready var cost_label: RichTextLabel = $MarginContainer/HBoxContainer/CostText

@export var item_data: ItemData

@export var cost: int

func _ready() -> void:
	item_name_label.text = ""
	cost_label.text = ""
	if item_data:
		set_item_data(item_data)

func set_item_data(item: ItemData) -> void:
	if item:
		item_data = item
		
		item_sprite.texture = item_data.sprite
		item_name_label.text = item_data.pretty_name
		cost_label.text = str(item_data.buy_price) + " Gold"
		
	else:
		item_data = null
		item_sprite.texture = null
		printerr("No item_data attached to shop slot.")

func update_popup() -> void:
	if item_data == null:
		return
	
	Popups.ItemPopup(item_data)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		slot_clicked.emit(item_data, event.button_index)


func _on_mouse_entered() -> void:
	update_popup()


func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
