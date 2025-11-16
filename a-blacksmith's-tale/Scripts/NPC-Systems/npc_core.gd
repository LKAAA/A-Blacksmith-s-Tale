extends CharacterBody2D
class_name NPCCore

const STUCK_THRESHOLD: float = 0.5

@export var char_name: String = ""

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var interact_area: Interactable = $InteractArea
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var visual_path_line2D: Line2D = null

@export var time_until_phase_through_objects: float = 2
@export var phase_duration: float = 2.5

var schedule: Array = [] # parsed schedule for today
var schedule_index: int = 0

var move_speed: float = 50.0
var base_move_speed: float = 50.0
var previous_position: Vector2 = Vector2.ZERO

var target_pos: Vector2
var current_path_index: int = 0
var target_zone: int
var moving: bool = false
var facing: int

var phasing: bool = false

var path_to_position: Array = []

signal request_dialogue(object)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")
	Global.time_changed.connect(_on_time_changed)
	z_index = 3

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
		var path = Grid.get_path_to_pos(prev_pos, event["pos"])
		
		var total_distance = 0.0
		for i in range(path.size() - 1):
			total_distance += path[i].distance_to(path[i + 1])
		
		var travel_time = total_distance / move_speed
		var travel_minutes = Global.core.time_manager.calculate_departure_time(event["time"], travel_time)
		
		event["departure time"] = travel_minutes
		
		prev_pos = event["pos"]
	
	return final_schedule

func _move_to(pos: Vector2, zone: int):
	var raw_path = Grid.get_path_to_pos(position, pos)
	var offset = Vector2(Global.TILE_SIZE / 2, Global.TILE_SIZE / 2)  # e.g. Vector2(8, 8) for 16x16 tiles

	for p in raw_path:
		path_to_position.append(p + offset)
	
	visual_path_line2D.points = path_to_position
	
	current_path_index = 1
	
	target_pos = path_to_position[current_path_index]
	target_zone = zone
	print("%s started moving." % char_name)
	moving = true

func _physics_process(_delta: float) -> void:
	if Global.dialogue_active:
		sprite_2d.play("IdleDown")
	elif Global.game_paused:
		sprite_2d.stop()
	
	# capture previous world position BEFORE movement
	var prev_pos: Vector2 = global_position
	
	if moving and not Global.game_paused: 
		var dir = (target_pos - global_position).normalized()
		velocity = dir * move_speed
		velocity = velocity.limit_length(move_speed)
		
		move_animations(dir)
		move_and_slide()
		
		if global_position.distance_to(target_pos) < 2.0:
			# reached target
			
			if (current_path_index + 1) == path_to_position.size(): # Final Position
				idle_animations()
				visual_path_line2D.clear_points()
				moving = false
				print("%s has arrived." % char_name)
				if target_zone != Global.cur_zone_id:
					print("In the wrong zone")
			else:
				#print("%s is going to the next point." % char_name)
				current_path_index += 1
				target_pos = path_to_position[current_path_index]
		
		# ---- Stuck detection ----
	var moved_distance = global_position.distance_to(prev_pos)
	if moving and not Global.game_paused:
		if moved_distance <= STUCK_THRESHOLD and not phasing:
			# just got stuck (or still stuck) — start timer if not already running
			if timer.is_stopped():
				timer.wait_time = time_until_phase_through_objects
				timer.start()
				print("%s: stopped moving, will phase in %s s" % [char_name, str(time_until_phase_through_objects)])
		else:
			# moved — cancel waiting timer if it was running and we are not phasing
			if not timer.is_stopped() and not phasing:
				timer.stop()
				print("%s: resumed moving — cancelled phase timer" % char_name)
	

func idle_animations() -> void:
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


func _on_timer_timeout() -> void:
	if not phasing:
		# Begin phasing
		collision_shape_2d.disabled = true
		phasing = true
		move_speed = base_move_speed + 20  # explicit set, avoids drift
		timer.wait_time = phase_duration
		timer.start()
		print("%s: started phasing" % char_name)
	else:
		# End phasing
		collision_shape_2d.disabled = false
		phasing = false
		move_speed = base_move_speed
		# don't restart the waiting timer here — let physics detect if still stuck
		timer.stop()
		timer.wait_time = time_until_phase_through_objects
		print("%s: stopped phasing" % char_name)
