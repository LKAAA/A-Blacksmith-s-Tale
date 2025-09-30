extends Node
class_name TimeManager

# Daylight Cycle Modulate
@onready var daylight_cycle_modulator: CanvasModulate = $"../DaylightCycleModulator"
@export var gradient: GradientTexture1D

@export var INITIAL_HOUR: int = 6:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR

# Time constants
const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

# Variables
var season: int
var day: int
var current_weekday: String
var current_season: String
var am_or_pm: String
var hour: int
var hour_12: int = 1
var minute: int
var pretty_day: String

var time: float = 0.0
var past_minute: float = -1.0
var past_hour: float = -1.0

# Signals
signal time_tick(_day: int, _hour: int, _hour_12: int, _minute: int, _current_weekday: String, _current_season: String, _am_or_pm: String)
signal day_end(next_day)
signal hour_passed

func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	season = 1
	day = 1
	decideSeason()
	decideWeekday()
	_recalculate_time()
	emit_current_time()

func _process(delta: float) -> void:
	_handle_debug_inputs()
	
	if not Global.game_paused:
		time += delta * INGAME_TO_REAL_MINUTE_DURATION * Global.INGAME_SPEED
		_recalculate_time()
		_set_canvas_color()
		
		if am_or_pm == "AM" && hour == 2:
			day_end.emit(day + 1)
			new_day()

func _handle_debug_inputs() -> void:
	#if Input.is_action_just_pressed("debug_slow_down_time"):
		#Global.INGAME_SPEED = max(1.0, Global.INGAME_SPEED - 5.0)
	
	#if Input.is_action_just_pressed("debug_speed_up_time"):
		#Global.INGAME_SPEED += 5
	pass

func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	
	hour = int(current_day_minutes / MINUTES_PER_HOUR)
	minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if day == 30:
		season += 1
		day = 0
	
	if past_hour != hour:
		hour_passed.emit(hour)
	
	if past_minute != minute:
		past_minute = minute
		_calculate_time_properties()
	

func _calculate_time_properties() -> void:
	hour_12 = hour if hour <= 12 else hour - 1
	am_or_pm = "AM" if hour < 12 else "PM"
	if hour == 0: hour_12 = 12
	decideWeekday()
	decideSeason()
	get_pretty_day()
	Global.cur_hour = hour_12
	Global.cur_minute = minute
	Global.am_pm = am_or_pm
	emit_current_time()

func _set_canvas_color() -> void:
	var value = (sin (time - PI / 2) + 1.0) / 2.0
	if am_or_pm == "AM":
		daylight_cycle_modulator.color = gradient.gradient.sample(value - 0.1) # Make it a tiny bit darker in the morning
	if am_or_pm == "PM":
		daylight_cycle_modulator.color = gradient.gradient.sample(value + 0.1) # Delay it getting dark by a tiny bit

func new_day():
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	day += 1
	decideWeekday()
	
	if day == 29:
		season += 1
		day = 1
		
		decideWeekday()
		decideSeason()
	_calculate_time_properties()

func decideWeekday():
	match day:
		1,8,15,22:
			current_weekday = "Monday"
		2,9,16,23:
			current_weekday = "Tuesday"
		3,10,17,24:
			current_weekday = "Wednesday"
		4,11,18,25:
			current_weekday = "Thursday"
		5,12,19,26:
			current_weekday = "Friday"
		6,13,20,27:
			current_weekday = "Saturday"
		7,14,21,28:
			current_weekday = "Sunday"
	Global.cur_day = current_weekday

func decideSeason():
	match season:
		1:
			current_season = "Spring"
		2:
			current_season = "Summer"
		3: 
			current_season = "Fall"
		4: 
			current_season = "Winter"
	Global.cur_season = current_season

func get_pretty_day():
	match day:
		1, 21, 31:
			pretty_day = "%dst" % day
		2, 22:
			pretty_day = "%dnd" % day
		3, 23:
			pretty_day = "%drd" % day
		_:
			pretty_day = "%dth" % day

func emit_current_time() -> void:
	#print("%s\n %s, Day: %d\n%02d:%02d %s" % [current_season, current_weekday, day, hour_12, minute, am_or_pm])
	time_tick.emit(pretty_day, hour, hour_12, minute, current_weekday, current_season, am_or_pm)
	Global.time_changed.emit((hour * 100) + minute)

func calculate_departure_time(arrival_time: int, irl_seconds: float) -> int:
	var ingame_minutes = irl_seconds_to_ingame_minutes(irl_seconds)

	# Break down arrival into hours/minutes
	var arrival_hour = int(arrival_time / 100)
	var arrival_minute = int(arrival_time % 100)

	# Convert arrival into total minutes since midnight
	var arrival_total_minutes = arrival_hour * MINUTES_PER_HOUR + arrival_minute

	# Subtract travel minutes
	var departure_total_minutes = arrival_total_minutes - int(round(ingame_minutes))

	# Wrap around if it goes negative (previous day)
	if departure_total_minutes < 0:
		departure_total_minutes += MINUTES_PER_DAY

	# Convert back to HHMM
	var dep_hour = int(departure_total_minutes / MINUTES_PER_HOUR)
	var dep_minute = int(departure_total_minutes % MINUTES_PER_HOUR)
	
	return dep_hour * 100 + dep_minute

# Converts real-life seconds into in-game minutes
func irl_seconds_to_ingame_minutes(irl_seconds: float) -> float:
	return irl_seconds * Global.INGAME_SPEED
