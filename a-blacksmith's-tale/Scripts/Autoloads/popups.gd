extends Control

var mouse_pos: Vector2
var padding_x = 6
var padding_y = 12
var correction = Vector2i()
var grabbed_item = false

@onready var name_label: Label = %Name_Label
@onready var type_label: Label = %Type_Label
@onready var description_label: Label = %Description_Label

func _ready() -> void:
	%ItemPopup.unfocusable = true

func _physics_process(_delta: float) -> void:
	if grabbed_item:
		padding_x = 24
		padding_y = 22
	else:
		padding_x = 8
		padding_y = 10
	mouse_pos = get_viewport().get_mouse_position()
	var clamped_y = clampf(mouse_pos.y + padding_y, 0, get_viewport_rect().size.y - %ItemPopup.size.y)
	
	%ItemPopup.position = Vector2(mouse_pos.x + padding_x, clamped_y)

func ItemPopup(item: ItemData):
	if not item:
		%ItemPopup.size = Vector2i.ZERO
		return
	
	name_label.text = item.name
	type_label.text = item.type
	description_label.text = item.description
		
	%ItemPopup.popup()

func HideItemPopup():
	%ItemPopup.hide()
