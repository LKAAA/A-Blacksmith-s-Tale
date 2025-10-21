extends StaticBody2D
class_name Barrel

@onready var interact_area: Interactable = $InteractArea

@onready var sprite: AnimatedSprite2D = $Sprite

signal toggle_inventory(external_inventory_owner)

@export var filled: bool = true
@export var uses: int = 999

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")
	update_barrel()

func update_barrel() -> void:
	if filled: 
		sprite.play("Filled")
	else:
		sprite.play("Empty")

func _on_interact() -> void:
	print("Water barrel used")
	filled = !filled
	update_barrel()
	
