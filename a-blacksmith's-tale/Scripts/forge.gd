extends StaticBody2D
class_name Forge


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var bellows_manager: BellowsManager = $Bellows_Manager
@onready var forge_manager: ForgeManager = $Forge_Manager


var active: bool = false

func _ready() -> void:
	bellows_manager.bellows_interacted.connect(_bellows_interacted)
	forge_manager.forge_interacted.connect(_forge_interacted)

func _forge_interacted() -> void:
	animated_sprite_2d.play("On")

func _bellows_interacted() -> void:
	animated_sprite_2d.play("Idle")
