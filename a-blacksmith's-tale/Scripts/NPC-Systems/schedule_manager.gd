extends Node

var npc_schedules: Dictionary = {}    # { npc_name: { "spring": "...", "fall": "...", ... } }
var todays_schedules: Dictionary = {} # { npc_name: schedule_string }

# ---------------------------------------------------------
# Schedule selection
# ---------------------------------------------------------
func _decide_todays_schedules() -> void:
	print("Get today's schedules")
	if not npc_schedules:
		_interpret_schedules()
	
	var season = Global.cur_season.to_lower()
	var day = Global.cur_day.to_lower()
	var season_day = season + "_" + day
	
	for npc in npc_schedules:
		var priority_keys: Array = []
		if Global.is_raining:
			priority_keys.append("rain")
		priority_keys.append(season_day)
		priority_keys.append(day)
		priority_keys.append(season)
	
		for key in priority_keys:
			if npc_schedules[npc].has(key):
				todays_schedules[npc] = npc_schedules[npc][key]
				print("NPC: %s, Chosen schedule: %s" % [npc, key])
				break

# ---------------------------------------------------------
# Read schedules from disk
# ---------------------------------------------------------
func _interpret_schedules():
	var dir = DirAccess.open("res://Data/Schedules/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var file = FileAccess.open("res://Data/Schedules/" + file_name, FileAccess.READ)
				var json_conv = JSON.new()
				json_conv.parse(file.get_as_text())
				var npc_name = file_name.trim_suffix(".json")
				npc_schedules[npc_name] = json_conv.get_data()
				print("Loaded schedule for %s" % npc_name)
			file_name = dir.get_next()
	else:
		printerr("Could not access schedules directory")

# ---------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------
func parse_schedule_entry(entry: String) -> Array:
	# Example entry: "800 (15.0, 336.0) 0 1 / 1000 (50.0, 120.0) 2 2 / "
	var parts = entry.strip_edges().split(" / ", false)
	var result: Array = []

	for part in parts:
		if part == "":
			continue
		
		# First token is time
		var first_space = part.find(" ")
		var time = int(part.substr(0, first_space))

		# Extract position inside parentheses
		var start_paren = part.find("(")
		var end_paren = part.find(")")
		var pos_str = part.substr(start_paren + 1, end_paren - start_paren - 1)
		var pos_parts = pos_str.split(",")
		var pos = Vector2(pos_parts[0].to_float(), pos_parts[1].to_float())

		# Remaining tokens (after pos)
		var remainder = part.substr(end_paren + 1).strip_edges()
		var tokens = remainder.split(" ")

		var facing = int(tokens[0])
		var zone_id = int(tokens[1])

		result.append({
			"time": time,
			"pos": pos,
			"facing": facing,
			"zone": zone_id
		})
	return result

func get_current_event(schedule_str: String, cur_time: int) -> Dictionary:
	var events = parse_schedule_entry(schedule_str)
	if events.is_empty():
		print("Oh no events is empty")
		return {}

	var closest_event: Dictionary = events[0]
	var smallest_diff: int = abs(cur_time - closest_event["time"])

	for event in events:
		var diff = abs(cur_time - event["time"])
		if diff < smallest_diff:
			smallest_diff = diff
			closest_event = event

	return closest_event

# ---------------------------------------------------------
# Zone population
# ---------------------------------------------------------
func get_zone_npcs(cur_zone_id: int, cur_time: int) -> Dictionary:
	# Ensures we have today's schedules
	if todays_schedules.is_empty():
		_decide_todays_schedules()
	var npcs_to_load: Dictionary = {} # { npc_name: event_dict }

	for npc in todays_schedules:
		var schedule_str = todays_schedules[npc]
		var event = get_current_event(schedule_str, cur_time)
		if event.is_empty():
			continue

		if event["zone"] == cur_zone_id:
			npcs_to_load[npc] = event
			print("Load NPC %s at %s in zone %s" % [npc, str(event["pos"]), str(cur_zone_id)])

	return npcs_to_load
