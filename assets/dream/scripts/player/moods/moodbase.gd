## Moodbase script
class_name Mood extends Node

var mood_manager : MoodManager
var controller : PlayerController

# Each mood overrides these
func enter_mood() -> void:
	pass

func exit_mood() -> void:
	pass

func process_mood(delta: float) -> void:
	pass
	
# Neutral uses defaults - no need to override, but can be explicit:
func get_multipliers() -> Dictionary:
	return {
		"attack": 1.0,
		"defense": 1.0,
		"speed": 1.0
	}
