extends Control

var mouse_pos: Vector2
var padding = 6
var correction = Vector2i()

@onready var name_label: Label = %Name_Label
@onready var type_label: Label = %Type_Label
@onready var description_label: Label = %Description_Label


func _physics_process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	%ItemPopup.position = Vector2(mouse_pos.x + padding, mouse_pos.y + padding)

func ItemPopup(slot: Rect2i,item: ItemData):
	if item != null:
		%ItemPopup.size = Vector2i.ZERO
	
	name_label.text = item.name
	type_label.text = item.type
	description_label.text = item.description
	
	%ItemPopup.popup()

func HideItemPopup():
	%ItemPopup.hide()
