class_name ItemPickup 
extends Area2D

@onready var sprite_2d: Sprite2D = %Sprite2D

@export var speed: float = 50
@export var item: StackData

var overlapping: bool
var inside: bool
var player: PlayerBase

func _ready() -> void:
	if item:
		sprite_2d.texture = item.item.sprite
	else:
		push_error("No item on this pickup.")

func _physics_process(delta: float) -> void:
	if overlapping: 
		position = position.move_toward(player.position, speed*delta)
	
	if inside: 
		var picked_up = player.inventory.add_item(item)
		if picked_up:
			queue_free()

func _on_outer_body_entered(body: Node2D) -> void:
	print("Move towards")
	if body: 
		player = body
		overlapping = true

func _on_inner_area_body_entered(body: Node2D) -> void:
	print("Pick up " + item.item.name)
	if body:
		inside = true

func _on_outer_body_exited(body: Node2D) -> void:
	overlapping = false


func _on_inner_area_body_exited(body: Node2D) -> void:
	inside = false
