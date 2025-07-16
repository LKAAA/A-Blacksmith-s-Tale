extends Control
class_name Dialogue

@onready var content: RichTextLabel = $MarginContainer/Content
@onready var type_timer: Timer = $TypeTimer
@onready var pause_timer: Timer = $PauseTimer
@onready var dialogue_voice_player: AudioStreamPlayer = $DialogueVoicePlayer
@onready var pause_calculator: Node = $PauseCalculator

var _playing_voice := false

signal message_completed()

func update_message(message: String) -> void:
	content.bbcode_text = pause_calculator.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	dialogue_voice_player.playSFX(0)

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

func _on_dialogue_voice_player_finished() -> void:
	if _playing_voice:
		dialogue_voice_player.playSFX(0)

func _on_pause_timer_timeout() -> void:
	_playing_voice = true
	dialogue_voice_player.playSFX(0)
	type_timer.start()

func _on_pause_calculator_pause_requested(duration: Variant) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()
