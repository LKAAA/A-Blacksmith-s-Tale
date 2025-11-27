extends Control
class_name InventorySlot

@onready var sprite: TextureRect = %Sprite
@onready var quantity_label: RichTextLabel = %Quantity_Label
@onready var background: TextureRect = %Background

signal slot_clicked(index: int, button: int)

var item_stack: ItemStack: 
	set = set_item_stack, get = get_item_stack

func _ready() -> void:
	quantity_label.text = ""

func update_slot(_item_stack: ItemStack) -> void:
	if not _item_stack:
		sprite.texture = null
		quantity_label.hide()
		return
	
	var item_data = _item_stack.item_data
	
	if item_data.sprite:
		sprite.texture = item_data.sprite
	
	if _item_stack.quantity > 1:
		quantity_label.text = "%d" % _item_stack.quantity
		quantity_label.show() 
	else:
		quantity_label.hide()

func set_item_stack(new_stack) -> void:
	item_stack = new_stack
	update_slot(item_stack)

func get_item_stack() -> ItemStack:
	if item_stack:
		#print("This slot does have an item stack attached: ", item_stack.item_data.name)
		return item_stack
	else:
		#print("This slot does not currently have an item stack attached")
		return null

func _on_mouse_entered() -> void:
	if item_stack and not Popups.active: 
		Popups.show_item_popup(item_stack.item_data)

func _on_mouse_exited() -> void:
	Popups.hide_item_popup()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		#print("Slot clicked: " + str(get_index()))
		slot_clicked.emit(get_index(), event.button_index)
