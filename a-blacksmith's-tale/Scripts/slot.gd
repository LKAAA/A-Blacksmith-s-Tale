class_name Slot extends Panel

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

@export var slot_data: SlotData

func _ready() -> void:
	label.text = ""
	if slot_data:
		set_slot_data(slot_data)

func set_slot_data(slot: SlotData) -> void:
	
	if slot:
		slot_data = slot
		if slot_data.item_data.sprite:
			texture_rect.texture = slot_data.item_data.sprite
		
		if slot_data.quantity > 1:
			label.text = str(slot_data.quantity)
			label.show()
		else:
			label.hide()
	else:
		slot_data = null
		texture_rect.texture = null
		label.hide()

func update_popup() -> void:
	if slot_data == null:
		return
	
	Popups.ItemPopup(slot_data.item_data)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		print("Slot clicked: " + str(get_index()))
		slot_clicked.emit(get_index(), event.button_index)


func _on_mouse_entered() -> void:
	update_popup()


func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
