extends CharacterBody2D
class_name NPCCore

@export var char_name: String = ""

@onready var interact_area: Interactable = $InteractArea
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var visual_path_line2D: Line2D = null

var schedule: Array = [] # parsed schedule for today
var schedule_index: int = 0

var move_speed: float = 60.0

var target_pos: Vector2
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
	schedule = ScheduleManager.parse_schedule_entry(schedule_data)
	schedule.sort_custom(func(a, b): return a["time"] < b["time"]) # sort by time
	schedule_index = 1

func _on_time_changed(cur_time) -> void:
	if schedule.is_empty():
		return
	
	print(cur_time)
	if schedule_index < schedule.size() and cur_time >= schedule[schedule_index]["time"]:
		# new target unlocked
		var target = schedule[schedule_index]
		_move_to(target["pos"], target["zone"])
		schedule_index += 1


func _move_to(pos: Vector2, zone: int):
	visual_path_line2D.position = self.position
	visual_path_line2D.z_index = 99
	path_to_position = Global.grid.get_path_to_pos(self.global_position, pos)
	print(path_to_position)
	visual_path_line2D.points = path_to_position
	target_pos = pos
	target_zone = zone
	moving = true

#func _physics_process(delta: float) -> void:
	#if not moving: return
	#
	#if not navigation_agent_2d.is_target_reached():
		#var nav_point_direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		#velocity = nav_point_direction * move_speed
		#move_and_slide()
		#
		#if target_zone != Global.cur_zone_id:
			#print("In the wrong zone")
	#else:
		#moving = false
#
