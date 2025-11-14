class_name Slot extends Panel

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

@export var slot_data: SlotData

func _ready() -> void:
	label.text = ""
	slot_data = SlotData.new()
	if slot_data.item_stack:
		set_slot_data(slot_data.item_stack)
	if slot_data.locked:
		self.self_modulate = Color.RED

func set_slot_data(item_stack: ItemStack) -> void:
	if not item_stack or not item_stack.item_data:
		texture_rect.texture = null
		label.hide()
		return
	
	if slot_data.item_data.sprite:
		texture_rect.texture = slot_data.item_data.sprite
	
	if slot_data.item_stack.quantity > 1:
		label.text = str(slot_data.item_stack.quantity)
		label.show()
	else:
		label.hide()

func update_popup() -> void:
	Popups.ItemPopup(get_item_data())

func is_locked() -> bool:
	return slot_data.locked

func set_locked(value: bool) -> void:
	if not slot_data: 
		return
	
	slot_data.locked = value

func get_item_data() -> ItemData:
	if not slot_data.item_stack or not slot_data.item_stack.item_data:
		return null
	return slot_data.item_stack.item_data

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		if not slot_data.locked:
			print("Slot clicked: " + str(get_index()))
			slot_clicked.emit(get_index(), event.button_index)
		else:
			print("This slot is locked.")

func _on_mouse_entered() -> void:
	update_popup()

func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
