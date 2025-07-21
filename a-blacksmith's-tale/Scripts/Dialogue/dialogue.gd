extends Control
class_name Dialogue

@onready var content: RichTextLabel = $MarginContainer/Content
@onready var type_timer: Timer = $TypeTimer
@onready var pause_timer: Timer = $PauseTimer
@onready var pause_calculator: Node = $PauseCalculator
@onready var random_sound_player: RandomSoundPlayer = $RandomSoundPlayer

var instant_dialogue: bool = false

var _playing_voice := false

signal message_completed()

func update_message(message: String, instant_dia: bool) -> void:
	instant_dialogue = instant_dia
	content.bbcode_text = pause_calculator.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	random_sound_player.playSFX(0)

func _on_type_timer_timeout() -> void:
	pause_calculator.check_at_position(content.visible_characters)
	if content.visible_characters < content.get_total_character_count():
		content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		message_completed.emit()

# Returns true if there are no pending characters to show
func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.get_total_character_count() - 1

func fast_forward_message() -> void:
	content.visible_characters = content.get_total_character_count()
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

func _on_pause_calculator_pause_requested(duration: Variant) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()
