extends CharacterBody2D
class_name NPCCore

@export var char_name: String = ""

@onready var interact_area: Interactable = $InteractArea
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@export var visual_path_line2D: Line2D = null

var core: Core

var schedule: Array = [] # parsed schedule for today
var schedule_index: int = 0

var move_speed: float = 50.0

var target_pos: Vector2
var current_path_index: int = 0
var target_zone: int
var moving: bool = false
var facing: int

var path_to_position: Array = []

signal request_dialogue(object)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")
	Global.time_changed.connect(_on_time_changed)

func _on_interact() -> void:
	request_dialogue.emit(self)
	print("Interact with " + char_name)

func set_schedule(schedule_data: String):
	print("HERE")
	schedule = ScheduleManager.parse_schedule_entry(schedule_data)
	schedule.sort_custom(func(a, b): return a["time"] < b["time"]) # sort by time
	schedule_index = 1

func _on_time_changed(cur_time) -> void:
	if schedule.is_empty():
		return
	
	if schedule[1]["departure time"] == 0: 
		schedule = calculate_travel_times(schedule)
	
	if schedule_index < schedule.size() and cur_time >= schedule[schedule_index]["departure time"]:
		# new target unlocked
		var target = schedule[schedule_index]
		_move_to(target["pos"], target["zone"])
		facing = target["facing"]
		schedule_index += 1

func calculate_travel_times(sch: Array) -> Array:
	var final_schedule = sch.duplicate()
	print("Final schedule: ", final_schedule)
	var prev_pos = final_schedule[0]["pos"] # initial_pos
	for event in final_schedule:
		var path = Global.grid.get_path_to_pos(prev_pos, event["pos"])
		
		var total_distance = 0.0
		for i in range(path.size() - 1):
			total_distance += path[i].distance_to(path[i + 1])
		
		var travel_time = total_distance / move_speed
		var travel_minutes = core.time_manager.calculate_departure_time(event["time"], travel_time)
		
		event["departure time"] = travel_minutes
		
		prev_pos = event["pos"]
	
	return final_schedule

func _move_to(pos: Vector2, zone: int):
	path_to_position = Global.grid.get_path_to_pos(position, pos)
	
	visual_path_line2D.points = path_to_position
	
	current_path_index = 1
	
	target_pos = path_to_position[current_path_index]
	target_zone = zone
	print("%s started moving." % char_name)
	moving = true

func _physics_process(delta: float) -> void:
	if Global.game_paused:
		sprite_2d.stop()
	
	if moving and not Global.game_paused: 
		var dir = (target_pos - global_position).normalized()
		velocity = dir * move_speed
		velocity = velocity.limit_length(move_speed)
		
		move_animations(dir)
		move_and_slide()
		
		if global_position.distance_to(target_pos) < 2.0:
			# reached target
			
			if (current_path_index + 1) == path_to_position.size(): # Final Position
				idle_animations(facing)
				visual_path_line2D.clear_points()
				moving = false
				print("%s has arrived." % char_name)
				if target_zone != Global.cur_zone_id:
					print("In the wrong zone")
			else:
				print("%s is going to the next point." % char_name)
				current_path_index += 1
				target_pos = path_to_position[current_path_index]
	

func idle_animations(dir) -> void:
	match facing:
		1: # down
			sprite_2d.play("IdleDown")
		2: # Left
			sprite_2d.play("IdleLeft")
		3: # Up
			sprite_2d.play("IdleUp")
		4: # Right
			sprite_2d.play("IdleRight")

func move_animations(dir) -> void:
	if roundf(dir.x) > 0:
		sprite_2d.play("WalkRight")
	elif roundf(dir.x) < 0:
		sprite_2d.play("WalkLeft")
	elif roundf(dir.y) < 0:
		sprite_2d.play("WalkUp")
	elif roundf(dir.y) > 0:
		sprite_2d.play("WalkDown")
