extends Node
class_name DialogueManager

const DIALOGUE_SCENE := preload("res://Scenes/dialogue.tscn")
@onready var dialogue_position: Marker2D = $"../UI/DialoguePosition"

signal message_requested()
signal message_completed()
signal finished()

var _messages := []
var cur_char: String
var _active_dialogue_offset := 0
var _is_active := false
var cur_dialogue_instance: Dialogue

func show_messages(message_list: Array, instant_dialogue: bool, char_name: String = "") -> void:
	# Only allow triggering if not currently showing something
	if _is_active:
		print("Dialogue is already active")
		return
	
	if message_list == []:
		print("No Dialogue to Choose")
		return
	
	# Pause game while showing messages
	Global.game_paused = true
	Global.dialogue_active = true
	
	_is_active = true
	
	_messages = message_list
	cur_char = char_name
	_active_dialogue_offset = 0
	
	var _dialogue = DIALOGUE_SCENE.instantiate()
	_dialogue.message_completed.connect(_on_message_completed)
	_dialogue.option_selected.connect(_on_option_selected)
	dialogue_position.add_child(_dialogue)
	
	cur_dialogue_instance = _dialogue
	
	_show_current(instant_dialogue)

func _show_current(instant_dialogue: bool) -> void:
	message_requested.emit()
	var message = _messages[_active_dialogue_offset]
	
	# Check for options (last element is a Dictionar with "options")
	if typeof(message) == TYPE_DICTIONARY and message.has("options"):
		cur_dialogue_instance.show_options(message["options"])
		print("Has dialogue choices")
	else:
		print("No dialogue choices")
		cur_dialogue_instance.update_message(message, instant_dialogue, cur_char)
	
	if instant_dialogue and typeof(message) != TYPE_DICTIONARY:
		cur_dialogue_instance.fast_forward_message()

func _on_option_selected(next_tag: String) -> void:
	_choose_message({"char_name": cur_char}, next_tag)

func _input(event: InputEvent) -> void:
	if (
		event.is_pressed() and 
		!event.is_echo() and
		(event is InputEventKey or event is InputEventMouseButton) and 
		event.is_action_pressed("ui_dialogue_interact") and
		_is_active and
		cur_dialogue_instance.message_is_fully_visible()  and not cur_dialogue_instance.options_section.visible
	):
		if _active_dialogue_offset < _messages.size() - 1:
			_active_dialogue_offset += 1
			_show_current(cur_dialogue_instance.instant_dialogue)
		else:
			_hide()
	elif(event.is_pressed() and 
		!event.is_echo() and
		(event is InputEventKey or event is InputEventMouseButton) and 
		event.is_action_pressed("ui_dialogue_interact") and
		_is_active and
		not cur_dialogue_instance.message_is_fully_visible()
	):
		cur_dialogue_instance.fast_forward_message()

func _hide() -> void:
	cur_dialogue_instance.disconnect("message_completed", _on_message_completed)
	cur_dialogue_instance.queue_free()
	cur_dialogue_instance = null
	_is_active = false
	Global.dialogue_active = false
	finished.emit()

func _on_message_completed() -> void:
	message_completed.emit()

func _choose_message(object, tag = "") -> void:
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
	
	# If there is a chosen message to go through (Options)
	if not tag == "":
		dialogue_file_data = get_dialogue_data(object)
		chosen_dialogue = get_dialogue_option(dialogue_file_data, tag)
		_hide()
		show_messages(chosen_dialogue, false, cur_char)
	
	if chosen_dialogue == []:
		dialogue_file_data = get_dialogue_data(object)
		chosen_dialogue = decide_dialogue_option(dialogue_file_data, object.char_name)
		show_messages(chosen_dialogue, false, object.char_name)
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

func get_dialogue_option(data: Dictionary, tag: String) -> Array:
	print("Get dialogue option")
	
	if data.has(tag):
		return data[tag]
	else:
		printerr("No dialogue for tag: " + tag)
		return []

func decide_dialogue_option(data: Dictionary, char_name: String) -> Array:
	print("Decide dialogue option")
	
	var priority_keys = _get_priority_keys(char_name)
	
	for key in priority_keys:
		if data.has(key):
			if key == "unmet":
				Progression.NPCS_MET[char_name] = true
				print("You just met " + char_name)
			
			print("Chose Dialogue: " + str(key))
			Progression.NPC_TALK_COUNT[char_name] += 1
			return data[key]
	
	print("No suitable dialogue option found")
	return []

func _get_priority_keys(char_name: String) -> Array:
	var season = Global.cur_season.to_lower()
	var day = Global.cur_day.to_lower()
	var season_day = season + "_" + day
	
	var keys := []

	# General unmet condition
	if not Progression.NPCS_MET[char_name]:
		keys.append("unmet")

	# Character-specific logic
	match char_name:
		"Seri":
			keys += _get_seri_priority_keys(char_name)

	# Weather and time priorities
	if Global.is_raining:
		keys.append("rain")
	keys += [season_day, day, season, "default"]

	return keys

func _get_seri_priority_keys(char_name: String) -> Array:
	var keys := []
	
	var talk_count: int = Progression.NPC_TALK_COUNT[char_name]
	var is_quest_active: bool = Progression.DIALOGUE_ADJUSTABLE_VARS["Seri_Quest_Active"]
	var name_known: bool = Progression.DIALOGUE_ADJUSTABLE_VARS["Seri_Name_Known"]
	
	if not is_quest_active:
		keys.append(str(talk_count + 1) + "_talk_found")
	else:
		keys.append(str(talk_count + 1) + "_talk_quest")
	
	if not name_known:
		keys.append("unknown_name")
	
	return keys
