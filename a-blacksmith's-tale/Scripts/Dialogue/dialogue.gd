extends Control
class_name Dialogue

@onready var type_timer: Timer = $TypeTimer
@onready var pause_timer: Timer = $PauseTimer
@onready var dialogue_commands: DialogueCommands = $DialogueCommands
@onready var random_sound_player: RandomSoundPlayer = $RandomSoundPlayer

#region Dialogue Section
@onready var dialogue_section: Control = $Dialogue_Section
@onready var dialogue_content: RichTextLabel = $Dialogue_Section/MarginContainer/Dialogue_Content
@onready var character_portrait_dialogue: TextureRect = %CharacterPortraitDialogue
@onready var char_name_section: Control = $Dialogue_Section/CharNameSection
@onready var character_name_label: RichTextLabel = %CharacterNameLabel
#endregion

#region Options Section
@onready var options_section: Control = $Options_Section
@onready var character_portrait_options: TextureRect = %CharacterPortraitOptions
signal option_selected(next_tag: String)

#endregion


var instant_dialogue: bool = false

var _playing_voice := false

signal message_completed()

func update_message(message: String, instant_dia: bool, npc_name: String = "") -> void:
	dialogue_section.visible = true
	options_section.visible = false
	
	instant_dialogue = instant_dia
	dialogue_content.bbcode_text = dialogue_commands.extract_pauses_from_string(message)
	dialogue_content.visible_characters = 0
	
	print(npc_name)
	if not npc_name == "":
		char_name_section.visible = true
		if Progression.DIALOGUE_ADJUSTABLE_VARS.has(npc_name + "_Name_Known"):
			if Progression.DIALOGUE_ADJUSTABLE_VARS[npc_name + "_Name_Known"] == false:
				character_name_label.bbcode_text = "?????"
			else:
				character_name_label.bbcode_text = npc_name
		else:
			character_name_label.bbcode_text = npc_name
		character_portrait_dialogue.visible = true
		#character_portrait.texture
	else:
		char_name_section.visible = false
		character_portrait_dialogue.visible = false
	
	type_timer.start()
	
	_playing_voice = true
	random_sound_player.playSFX(0)

func show_options(options: Array) -> void:
	options_section.visible = true
	dialogue_section.visible = false
	get_node("Options_Section/MarginContainer/VBoxContainer/Option1").visible = false
	get_node("Options_Section/MarginContainer/VBoxContainer/Option2").visible = false
	get_node("Options_Section/MarginContainer/VBoxContainer/Option3").visible = false
	get_node("Options_Section/MarginContainer/VBoxContainer/Option4").visible = false
	for i in range(options.size()):
		var option_data = options[i]
		var button = get_node("Options_Section/MarginContainer/VBoxContainer/Option" + str(i + 1)) as Button
		var background = get_node("Options_Section/MarginContainer3/VBoxContainer/OptionsBackground" + str(i + 1))
		background.visible = true
		button.visible = true
		button.text = option_data["text"]
		button.connect("pressed", Callable(self, "_on_option_selected").bind(option_data["next"]))

func _on_option_selected(next_tag: String) -> void:
	print("Option selected")
	option_selected.emit(next_tag)
	

func _on_type_timer_timeout() -> void:
	dialogue_commands.check_at_position(dialogue_content.visible_characters)
	if dialogue_content.visible_characters < dialogue_content.get_total_character_count():
		dialogue_content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		message_completed.emit()

# Returns true if there are no pending characters to show
func message_is_fully_visible() -> bool:
	return dialogue_content.visible_characters >= dialogue_content.get_total_character_count() - 1

func fast_forward_message() -> void:
	dialogue_content.visible_characters = dialogue_content.get_total_character_count()
	_playing_voice = false
	type_timer.stop()
	message_completed.emit()

func _on_random_sound_player_finished() -> void:
	if _playing_voice:
		random_sound_player.playSFX(0)

func _on_pause_timer_timeout() -> void:
	_playing_voice = true
	random_sound_player.playSFX(0)
	type_timer.start()

func _on_dialogue_commands_pause_requested(duration: Variant) -> void:
	print("HERE")
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()
