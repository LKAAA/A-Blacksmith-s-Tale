extends Node
class_name ScheduleManager

var npc_schedules: Dictionary = {}
var todays_schedules: Dictionary = {}

func _decide_todays_schedules() -> void:
	print("Get today's schedules")
	
	var season = Global.cur_season.to_lower()
	var day = Global.cur_day.to_lower()
	var season_day = season + "_" + day
	
	for npc in npc_schedules:
		var priority_keys = []
		if Global.is_raining:
			priority_keys.append("rain")
		priority_keys.append(season_day)
		priority_keys.append(day)
		priority_keys.append(season)
	
		for key in priority_keys:
			if npc_schedules[npc].has(key):
				todays_schedules[npc] = npc_schedules[npc][key]
				print("NPC: ", npc, ", Chosen schedule: ", key)
				break

func _interpret_schedules():
	var dir = DirAccess.open("res://Data/Schedules/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				var file = FileAccess.open("res://Data/Schedules/" + file_name, FileAccess.READ)
				var json_conv = JSON.new()
				json_conv.parse(file.get_as_text())
				print("Found Data")
				var npc_name = file_name.trim_suffix(".json")
				npc_schedules[npc_name] = json_conv.get_data()
			file_name = dir.get_next()
	else:
		printerr("An error occured when trying to access the path.")
