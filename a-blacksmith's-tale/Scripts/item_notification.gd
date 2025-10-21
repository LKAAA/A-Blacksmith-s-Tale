extends Node2D
class_name ItemNotification

@onready var item_sprite: Sprite2D = $Item
@onready var timer: Timer = $Timer

var up: bool = false

func update_noti(item_data: ItemData) -> void:
	item_sprite.texture = item_data.sprite
	timer.start()

func _on_timer_timeout() -> void:
	if up:
		position.y -= 1
		up = false
	else:
		position.y += 1
		up = true
