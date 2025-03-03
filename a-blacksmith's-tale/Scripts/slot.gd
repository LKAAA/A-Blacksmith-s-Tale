class_name Slot extends Panel

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

@export var slot_item_data: SlotData

func _ready() -> void:
	label.text = ""
	if slot_item_data:
		set_slot_data(slot_item_data)

func set_slot_data(slot_data: SlotData) -> void:
	if slot_data:
		slot_item_data = slot_data
		if slot_item_data.item_data.sprite:
			texture_rect.texture = slot_item_data.item_data.sprite
		
		if slot_data.quantity > 1:
			label.text = str(slot_data.quantity)
			label.show()
		else:
			label.hide()	

func _on_gui_input(event: InputEvent) -> void:
	print("Emitt")
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		print("Emitting")
		slot_clicked.emit(get_index(), event.button_index)
