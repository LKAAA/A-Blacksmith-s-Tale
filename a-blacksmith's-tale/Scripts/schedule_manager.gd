extends Node
class_name ScheduleManager

var npc_schedules: Dictionary = {}

func _interpret_schedule(npc_name: String):
	var file_path = "res://Data/Schedules/" + npc_name + ".json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_conv = JSON.new()
		json_conv.parse(file.get_as_text())
		print("Found Data")
		npc_schedules[npc_name] = json_conv.get_data()
		#return json_conv.get_data()
	printerr("Did not find Schedule for " + npc_name)
	#return {}
