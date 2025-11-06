extends Node

var time_passing := false
var current_day :int = 1
var current_hour :int = 0
var current_min: int = 0
var min_per_day := 24.0
var accumulated_seconds := 0.0
var real_seconds_per_game_minute: float

func _process(delta: float):
	if time_passing == false:
		return
	accumulated_seconds += delta
	while accumulated_seconds >= real_seconds_per_game_minute:
		accumulated_seconds -= real_seconds_per_game_minute
		current_min += 1
		if current_min >= 60:
			current_min = 0
			current_hour += 1
			if current_hour >= 24:
				current_hour = 0
				current_day += 1

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	update_time_ratio()
	
func update_time_ratio():
	real_seconds_per_game_minute = (min_per_day * 60) / 1440

## Helper Functions?

func start_clock():
	time_passing = true

func stop_clock():
	time_passing = false
	
func change_time_ratio(new_min_per_day: float):
	min_per_day = new_min_per_day
	update_time_ratio()

func get_current_time() -> Dictionary:
	return {
		"day": current_day,
		"hour": current_hour,
		"minute": current_min,
		"total_minutes": (current_day - 1) * 1440 + current_hour * 60 + current_min
	}
