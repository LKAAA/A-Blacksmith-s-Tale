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
	print("Choosing for: " + str(object))
	var chosen_dialogue = []
	var dialogue_file_data: Dictionary = {}
	var instant_dialogue: bool = false
	
	# If there is a file there will always be a tag - 
	# Because only reason a hardcoded file is in their is because the file has multiple character lines
	if "dialogue_file" in object:
		dialogue_file_data = load_dialogue(object.dialogue_file)
		chosen_dialogue = dialogue_file_data[object.dialogue_tag]
	
	if "dialogue_instant" in object:
		instant_dialogue = object.dialogue_instant
	
	if chosen_dialogue == []:
		dialogue_file_data = get_dialogue_data(object)
		chosen_dialogue = decide_dialogue_option(dialogue_file_data, object.char_name)
		show_messages(chosen_dialogue, false)
	else:
		show_messages(chosen_dialogue, instant_dialogue)

func get_dialogue_data(object) -> Dictionary:
	var dir = DirAccess.open("res://Data/Dialogue/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				var npc_name = file_name.trim_suffix(".json")
				if npc_name == object.char_name:
					var file = FileAccess.open("res://Data/Dialogue/" + file_name, FileAccess.READ)
					var json_conv = JSON.new()
					json_conv.parse(file.get_as_text())
					print("Found Data")
					return json_conv.get_data()
			file_name = dir.get_next()
		return {}
	else:
		printerr("An error occured when trying to access the path.")
		return {}

func decide_dialogue_option(data: Dictionary, char_name: String) -> Array:
	print("Get dialogue option")
	
	var season = Global.cur_season.to_lower()
	var day = Global.cur_day.to_lower()
	var season_day = season + "_" + day
	
	var priority_keys = []
	if not Progression.NPCS_MET[char_name]:
		priority_keys.append("unmet")
	if Global.is_raining:
		priority_keys.append("rain")
	priority_keys.append(season_day)
	priority_keys.append(day)
	priority_keys.append(season)
	priority_keys.append("default")

	for key in priority_keys:
		if data.has(key):
			if key == "unmet":
				Progression.NPCS_MET[char_name] = true
				print("You just met " + char_name)
			
			print("Chose Dialogue: " + str(key))
			return data[key]
	
	print("No suitable dialogue option found")
	return []

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
