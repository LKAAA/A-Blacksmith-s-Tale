extends Node
class_name DialogueCommands

# Regular expression to find {p=%d} tags
const PAUSE_PATTERN := "({p=\\d([.]\\d+)?[}])"

# Additional cleanup patterns
const BBCODE_I_PATTERN := "\\[(?!\\/)(.*?)\\]"
const BBCODE_E_PATTERN := "\\[\\/(.*?)\\]"

# Not that we are defining here that all of our custom tags will be defined as {%s}, so
# we use this global pattern to match all of them.
const CUSTOM_TAG_PATTERN := "({(.*?)})"

# List of pauses found for the last parsed string
var _pauses := []

# Pause Regex
var _pause_regex := RegEx.new()

# Auxiliary Regexes
var _bbcode_i_regex := RegEx.new()
var _bbcode_e_regex := RegEx.new()
var _custom_tag_regex := RegEx.new()

signal pause_requested(duration)

func _ready() -> void:
	# Tags
	_pause_regex.compile(PAUSE_PATTERN)

	# Auxiliary
	_bbcode_i_regex.compile(BBCODE_I_PATTERN)
	_bbcode_e_regex.compile(BBCODE_E_PATTERN)
	_custom_tag_regex.compile(CUSTOM_TAG_PATTERN)

func extract_pauses_from_string(source_string: String) -> String:
	_pauses = []
	var dialogue_string = source_string
	dialogue_string = _replacement_commands(dialogue_string)
	_find_pauses(dialogue_string)
	return _extract_tags(dialogue_string)

func check_at_position(pos: int) -> void:
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			emit_signal("pause_requested", _pause.duration)

func _find_pauses(source: String) -> void:
	print("Finding pauses")
	_pauses = []
	
	var index := 0
	var visible_index := 0
	
	while index < source.length():
		if source[index] == '{':
			var end_index := source.find('}', index)
			if end_index != -1:
				var tag := source.substr(index, end_index - index + 1)
				if tag.begins_with("{p="):
					var value := tag.substr(3, tag.length() - 4).to_float()
					_pauses.append(Pause.new(visible_index, tag))
				index = end_index + 1
				continue
		elif source[index] == '[':
			var end_index := source.find(']', index)
			if end_index != -1:
				# Skip BBCode tag
				index = end_index + 1
				continue
		
		# Count as visible character
		visible_index += 1
		index += 1

# Removes all custom tags from the string
func _extract_tags(from_string: String) -> String:
	return _custom_tag_regex.sub(from_string, "", true)

func _replacement_commands(dialogue_string: String) -> String:
	var final_string := dialogue_string
	var index := 0
	
	while index < final_string.length():
		# check text here
		if final_string[index] == '@':
			final_string = final_string.replace('@', Global.player_name)
		
		if final_string[index] == '{':
			var end_index := final_string.find('}', index)
			if end_index != -1:
				var tag := final_string.substr(index, end_index - index + 1)
				if tag.begins_with("{time"):
					final_string = final_string.replace('{time}', "%d:%02d" % [Global.cur_hour, Global.cur_minute])
				if tag.begins_with("{time_am"):
					final_string = final_string.replace('{time_am}', "%d:%02d %s" % [Global.cur_hour, Global.cur_minute, Global.am_pm])
				if tag.begins_with("{shop"):
					final_string = final_string.replace('{shop}', Global.player_shop_name)
				if tag.begins_with("{race"):
					final_string = final_string.replace('{race}', Global.player_race)
				
				if tag.begins_with("{var"):
					var var_index := tag.find('(') + 1
					var var_end_index := tag.find(')')
					
					if var_index == -1 or var_end_index == -1:
						push_error("Malformed var tag: missing parentheses")
						continue
					
					var var_name := tag.substr(var_index, var_end_index - var_index).strip_edges()
					var value_str := tag.substr(var_end_index + 1, tag.length() - var_end_index - 2).strip_edges()
					var value  : Variant
					print(value_str)
					
					match value_str.to_lower():
						"true": 
							value = true
						"false": 
							value = false
						_:
							if String(value_str).is_valid_float():
								value = float(value_str)
							elif String(value_str).is_valid_int():
								value = int(value_str)
							else:
								value = value_str # Fallback to string
					
					print("Setting variable: " + var_name + " = " + value_str)
					Progression.DIALOGUE_ADJUSTABLE_VARS[var_name] = value
				
				if tag.contains('^'):
					var midpoint_index := final_string.find('^', index)
					var selected_text := ""
					if Global.player_gender.to_lower() == "male":
						selected_text = final_string.substr(index + 1, midpoint_index - index - 1)
						
					if Global.player_gender.to_lower() == "female":
						selected_text = final_string.substr(midpoint_index + 1, end_index - midpoint_index - 1)
					
					var beginning = final_string.substr(0, index)
					var ending = final_string.substr(end_index + 1, final_string.length() - end_index)
					final_string = beginning + selected_text + ending
				
				index = end_index + 1
				continue
		
		index += 1
	
	return final_string
