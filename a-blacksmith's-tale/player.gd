class_name PlayerBase extends CharacterBody2D

# Player base handles movement and input

@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var inventory: InventoryData = InventoryData.new()

const WALKSPEED: float = 60 # Base walkspeed
const RUNSPEED: float = 90 # Base runspeed
var speed: float # current speed with any bonuses
var isSprinting: bool = false

const ROLLSPEED: float = 150

var input_vector: Vector2
var roll_vector: Vector2
var prev_direction: int

enum PLAYER_STATES { MOVE, DODGEROLL, ATTACK, INTERACTING }
var current_state: PLAYER_STATES 

signal open_inventory(inventory: InventoryData)

func _ready() -> void:
	speed = calculate_current_speed(0)

func _physics_process(delta: float) -> void:
	match current_state:
		PLAYER_STATES.MOVE:
			_handle_movement()
			_handle_input()
			_handle_movement_anims()
		PLAYER_STATES.DODGEROLL:
			pass
			
	move_and_slide()

func _handle_movement() -> void:
	input_vector = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
	velocity = input_vector * speed
	
	velocity = velocity.limit_length(speed)

func _handle_input() -> void:
	if Input.is_action_just_pressed("ui_sprint"):
		isSprinting = !isSprinting
		speed = calculate_current_speed(0)
	
	if Input.is_action_just_pressed("ui_dodgeroll"):
		dodgeroll()
	
	if Input.is_action_just_pressed("ui_inventory"):
		open_inventory.emit(inventory)

func dodgeroll() -> void:
	current_state = PLAYER_STATES.DODGEROLL
	#hitbox.enabled = false
	velocity = roll_vector.normalized() * ROLLSPEED
	sprite.play("Roll_Down")

func _handle_movement_anims() -> void:
	if current_state == PLAYER_STATES.MOVE:
		if input_vector.y < 0:
			sprite.play("Walk_Up")
			prev_direction = 1
		elif input_vector.y > 0:
			sprite.play("Walk_Down")
			prev_direction = 2
		elif input_vector.x > 0:
			sprite.play("Walk_Right")
			prev_direction = 3
		elif input_vector.x < 0:
			sprite.play("Walk_Left")
			prev_direction = 4
		else:
			_play_idle_animation()

func _play_idle_animation() -> void:
	match prev_direction:
		1: sprite.play("Idle_Up")
		2: sprite.play("Idle_Down")
		3: sprite.play("Idle_Right")
		4: sprite.play("Idle_Left")
		_: sprite.play("Idle_Down")

func calculate_current_speed(bonuses) -> float:
	if isSprinting:
		return RUNSPEED + bonuses
	else:
		return WALKSPEED + bonuses

func _on_sprite_2d_animation_finished() -> void:
	if current_state == PLAYER_STATES.DODGEROLL:
		#hitbox.enabled = true
		current_state = PLAYER_STATES.MOVE
