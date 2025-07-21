@tool
extends Node2D
class_name NPCScheduleTool

@export var schedule: Dictionary = {}

@export_category("Debug")
@export var json_file_name: String = ""
@export var cur_schedule_name: String = ""
@export var cur_schedule_time: int = 000
@export_tool_button("Record Schedule", "Callable") var record_data = _record_data
@export_tool_button("Delete Schedule", "Callable") var delete_data = _delete_data
@export_tool_button("Save To Json", "Callable") var save_to_json = _save_to_json

func _record_data():
	var cur_pos: Vector2 = get_parent().position
	var facing_direction = 0
	if schedule.has(cur_schedule_name):
		schedule[cur_schedule_name] += str(cur_schedule_time) + " " + str(cur_pos) + " " + str(facing_direction) + " / "
	else:
		schedule[cur_schedule_name] = str(cur_schedule_time) + " " + str(cur_pos) + " " + str(facing_direction) + " / "
	notify_property_list_changed()
	print(schedule)

func _delete_data():
	schedule.clear()
	notify_property_list_changed()
	print("Deleted")

func _save_to_json():
	var file_path = "res://Data/Schedules/" + json_file_name + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json_string = JSON.stringify(schedule)
	file.store_line(json_string)
	
	print("Save to Json")
