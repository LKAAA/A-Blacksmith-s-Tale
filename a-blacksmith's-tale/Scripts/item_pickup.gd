class_name ItemPickup 
extends Area2D

@onready var sprite_2d: Sprite2D = %Sprite2D

@export var speed: float = 50
@export var slot_data: SlotData

var overlapping: bool
var inside: bool
var player: PlayerBase

func _ready() -> void:
	if slot_data:
		sprite_2d.texture = slot_data.item_data.sprite
	else:
		push_error("No item on this pickup.")

func _physics_process(delta: float) -> void:
	if overlapping: 
		position = position.move_toward(player.position, speed*delta)
	
	if inside: 
		if player.inventory.pick_up_slot_data(slot_data):
			queue_free()

func _on_outer_body_entered(body: Node2D) -> void:
	if body: 
		player = body
		overlapping = true

func _on_inner_area_body_entered(body: Node2D) -> void:
	if body:
		inside = true

func _on_outer_body_exited(body: Node2D) -> void:
	overlapping = false


func _on_inner_area_body_exited(body: Node2D) -> void:
	inside = false
