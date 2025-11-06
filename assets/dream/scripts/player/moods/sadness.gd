extends Mood

func enter_mood() -> void:
	print("Entered Sadness mood!")

func exit_mood() -> void:
	print("Exited Sadness mood!")

func process_mood(delta: float) -> void:
	pass

func get_multipliers() -> Dictionary:
	if controller.current_mode_type == controller.Mode.DEMIDEVIL:
		return {
			"attack": 1.0,
			"defense": 0.7,   # -30% defense (everything hurts more)
			"speed": 0.9      # Slightly slower
		}
	else:  # DEMISE
		return {
			"attack": 1.0,
			"defense": 0.7,   # -30% defense (vulnerable)
			"speed": 0.85     # Slower (heavy)
		}
