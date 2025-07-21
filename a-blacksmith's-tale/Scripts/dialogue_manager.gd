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

func show_messages(message_list: Array, instant_dialogue: bool) -> void:
	# Only allow triggering if not currently showing something
	if _is_active:
		return
	
	if message_list == []:
		print("No Dialogue to Choose")
		return
	
	# Pause game while showing messages
	Global.game_paused = true
	
	_is_active = true
	
	_messages = message_list
	_active_dialogue_offset = 0
	
	var _dialogue = DIALOGUE_SCENE.instantiate()
	_dialogue.message_completed.connect(_on_message_completed)
	dialogue_position.add_child(_dialogue)
	
	cur_dialogue_instance = _dialogue
	
	_show_current(instant_dialogue)

func _show_current(instant_dialogue: bool) -> void:
	message_requested.emit()
	cur_dialogue_instance.update_message(_messages[_active_dialogue_offset], instant_dialogue)
	if instant_dialogue:
		cur_dialogue_instance.fast_forward_message()

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
			_show_current(cur_dialogue_instance.instant_dialogue)
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

func _choose_message(object) -> void:
	var chosen_dialogue = []
	var dialogue_file_data: Dictionary = {}
	var instant_dialogue: bool = false
	
	if "dialogue_file" in object:
		dialogue_file_data = load_dialogue(object.dialogue_file)
	
	if "dialogue_tag" in object:
		chosen_dialogue = dialogue_file_data[object.dialogue_tag]
	
	if "dialogue_instant" in object:
		instant_dialogue = object.dialogue_instant
	
	show_messages(chosen_dialogue, instant_dialogue)

func load_dialogue(file_name) -> Dictionary:
	var file_path = "res://Data/Dialogue/" + file_name + ".json"
	if FileAccess.file_exists(file_path):
		
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_conv = JSON.new()
		json_conv.parse(file.get_as_text())
		print("Found Data")
		return json_conv.get_data()
	print("Did not find Data")
	return {}
