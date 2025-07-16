extends Node
class_name DialogueManager

const DIALOGUE_SCENE := preload("res://Scenes/dialogue.tscn")
@onready var dialogue_position: Marker2D = $"../UI/DialoguePosition"

signal message_requested()
signal message_completed()
signal finished()

var _messages := []
var _active_dialogue_offset := 0
var _is_active := false
var cur_dialogue_instance: Dialogue

func show_messages(message_list: Array) -> void:
	# Only allow triggering if not currently showing something
	if _is_active:
		return
	
	_is_active = true
	
	_messages = message_list
	_active_dialogue_offset = 0
	
	var _dialogue = DIALOGUE_SCENE.instantiate()
	_dialogue.message_completed.connect(_on_message_completed)
	dialogue_position.add_child(_dialogue)
	
	cur_dialogue_instance = _dialogue
	
	_show_current()

func _show_current() -> void:
	message_requested.emit()
	cur_dialogue_instance.update_message(_messages[_active_dialogue_offset])

func _input(event: InputEvent) -> void:
	if (
		event.is_pressed() and 
		!event.is_echo() and
		event is InputEventKey and 
		event.keycode == KEY_ENTER and
		_is_active and
		cur_dialogue_instance.message_is_fully_visible()
	):
		if _active_dialogue_offset < _messages.size() - 1:
			_active_dialogue_offset += 1
			_show_current()
		else:
			_hide()
	elif(event.is_pressed() and 
		!event.is_echo() and
		event is InputEventKey and 
		event.keycode == KEY_ENTER and
		_is_active and
		not cur_dialogue_instance.message_is_fully_visible()
	):
		cur_dialogue_instance.fast_forward_message()

func _hide() -> void:
	cur_dialogue_instance.disconnect("message_completed", _on_message_completed)
	cur_dialogue_instance.queue_free()
	cur_dialogue_instance = null
	_is_active = false
	finished.emit()

func _on_message_completed() -> void:
	message_completed.emit()
