class_name PlayerBase extends CharacterBody2D

# Player base handles movement and input

@onready var all_interactions = []
@onready var all_breakables = []

@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var inventory: InventoryData = InventoryData.new()
@onready var stats_manager: CharacterStats = %StatsManager

var speed: float
var isSprinting: bool = false

const ROLLSPEED: float = 150

var input_vector: Vector2
var roll_vector: Vector2
var prev_direction: int

enum PLAYER_STATES { MOVE, DODGEROLL, ATTACK, INTERACTING }
var current_state: PLAYER_STATES 

signal open_inventory(inventory: InventoryData)
signal escape_ui
signal use
signal request_break

func _ready() -> void:
	speed = stats_manager.get_stat("Walk Speed").current

func _physics_process(delta: float) -> void:
	match current_state:
		PLAYER_STATES.MOVE:
			if not Global.game_paused:
				_handle_movement()
				_handle_movement_anims()
			_handle_input()
		PLAYER_STATES.DODGEROLL:
			pass
	
	if not Global.game_paused:
		move_and_slide()

func _handle_movement() -> void:
	input_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
	velocity = input_vector * speed
	
	velocity = velocity.limit_length(speed)

func _handle_input() -> void:
	
	if Input.is_action_just_pressed("inventory"):
		open_inventory.emit()
		_play_idle_animation()
	
	if Input.is_action_just_pressed("ui_leave"):
		escape_ui.emit()
	
	if not Global.game_paused:
		if Input.is_action_just_pressed("use"):
			execute_breakable()
			#use.emit()
		
		if Input.is_action_just_pressed("interact"):
			execute_interaction()
		
		if Input.is_action_just_pressed("sprint"):
			if isSprinting:
				isSprinting = false
				speed = stats_manager.get_stat("Walk Speed").current
			else:
				isSprinting = true
				speed = stats_manager.get_stat("Run Speed").current
		
		if Input.is_action_just_pressed("dodgeroll"):
			dodgeroll()

func dodgeroll() -> void:
	current_state = PLAYER_STATES.DODGEROLL
	#hitbox.enabled = false
	velocity = roll_vector.normalized() * ROLLSPEED
	sprite.play("Roll_Down")
# CHANGE EACH TO "WALK_XXXX" when walk anims are in
func _handle_movement_anims() -> void:
	if current_state == PLAYER_STATES.MOVE:
		if input_vector.y < 0:
			sprite.play("Idle_Up")
			prev_direction = 1
		elif input_vector.y > 0:
			sprite.play("Walk_Down")
			prev_direction = 2
		elif input_vector.x > 0:
			sprite.play("Idle_Right")
			prev_direction = 3
		elif input_vector.x < 0:
			sprite.play("Idle_Left")
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

func _on_sprite_2d_animation_finished() -> void:
	if current_state == PLAYER_STATES.DODGEROLL:
		#hitbox.enabled = true
		current_state = PLAYER_STATES.MOVE

# Interaction Funcs

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("breakable"):
		all_breakables.insert(0, area)
	if area.is_in_group("interactable"):
		print("Added Interaction")
		all_interactions.insert(0, area)

func _on_interaction_area_exited(area: Area2D) -> void:
	if area.is_in_group("breakable"):
		all_breakables.erase(area)
	if area.is_in_group("interactable"):
		all_interactions.erase(area)

func execute_interaction() -> void:
	if all_interactions:
		for i in all_interactions:
			if i.hovering:
				if i.get_parent().has_method("_on_interact"):
					i.get_parent()._on_interact()

func execute_breakable() -> void:
	if all_breakables:
		for i in all_breakables:
			if i.hovering:
				if i.get_parent().has_method("_on_hit"):
					request_break.emit(i.get_parent())
					#i.get_parent()._on_hit(get_active_item())
