extends Mood

func enter_mood() -> void:
	print("Entered Anger mood!")

func exit_mood() -> void:
	print("Exited Anger mood!")

func process_mood(delta: float) -> void:
	pass

func get_multipliers() -> Dictionary:
	if controller.current_mode_type == controller.Mode.DEMIDEVIL:
		return {
			"attack": 1.5,    # +50% damage (aggressive)
			"defense": 0.7,   # -30% defense (reckless)
			"speed": 1.0
		}
	else:  # DEMISE
		return {
			"attack": 1.0,
			"defense": 0.8,   # Take more damage when hit (on edge)
			"speed": 1.1      # Slight movement speed boost (irritable)
		}
