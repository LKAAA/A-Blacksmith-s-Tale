extends CharacterBody2D
class_name NPCCore

@export var char_name: String = ""

@onready var interact_area: Interactable = $InteractArea

var schedule: Array = [] # parsed schedule for today
var schedule_index: int = 0

var move_speed: float = 100.0

var target_pos: Vector2
var target_zone: int
var moving: bool = false
var facing: int

signal request_dialogue(object)

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	request_dialogue.emit(self)
	print("Interact with " + char_name)

func set_schedule(schedule_data: String):
	schedule = ScheduleManager.parse_schedule_entry(schedule_data)
	schedule.sort_custom(func(a, b): return a["time"] < b["time"]) # sort by time
	schedule_index = 0

func _process(delta: float) -> void:
	
	if schedule.is_empty():
		return
	
	var cur_time = Global.get_time() # Example: "830" means 8:30 AM
	if schedule_index < schedule.size() and cur_time >= schedule[schedule_index]["time"]:
		# new target unlocked
		var target = schedule[schedule_index]
		_move_to(target["pos"], target["zone"])
		schedule_index += 1

func _move_to(pos: Vector2, zone: int):
	target_pos = pos
	target_zone = zone
	moving = true

func _physics_process(delta: float) -> void:
	if moving:
		var dir = (target_pos - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
		
		if global_position.distance_to(target_pos) < 4.0:
			# reached target
			global_position = target_pos
			moving = false
			if target_zone != Global.cur_zone_id:
				print("In the wrong zone")
