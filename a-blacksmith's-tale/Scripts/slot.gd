class_name Slot extends Panel

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

@export var item_stack: ItemStack: 
	set = set_item_stack, get = get_item_stack
	
@export var locked: bool = false:
	set = set_locked, get = get_locked
@export var allowed_item_types: Array[String] = ["All"]

func _ready() -> void:
	label.text = ""

func update_slot(_item_stack: ItemStack) -> void:
	print("Updating slot")
	if not _item_stack:
		texture_rect.texture = null
		label.hide()
		return
	
	var item_data = _item_stack.item_data
	
	if item_data.sprite:
		texture_rect.texture = item_data.sprite
	
	if _item_stack.quantity > 1:
		label.text = str(_item_stack.quantity)
		label.show()
	else:
		label.hide()

func update_popup() -> void:
	print("Yuh")
	print(get_item_data())
	Popups.ItemPopup(get_item_data())

func get_locked() -> bool:
	return locked

func set_locked(value: bool) -> void:
	locked = value

func get_item_data() -> ItemData:
	if not item_stack:
		return null
	return item_stack.item_data

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		if not locked:
			print("Slot clicked: " + str(get_index()))
			slot_clicked.emit(get_index(), event.button_index)
		else:
			print("This slot is locked.")

func _on_mouse_entered() -> void:
	update_popup()

func _on_mouse_exited() -> void:
	Popups.HideItemPopup()

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
