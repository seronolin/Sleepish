extends Mood

var mode_at_swing

func enter_mood() -> void:
	print("Entered Joy mood!")
	# Give double jump if Demidevil
	if controller.current_mode_type == controller.Mode.DEMIDEVIL:
		controller.change_jump_count(2)
		mode_at_swing = controller.Mode.DEMIDEVIL
	else:
		controller.hp_manager.add_joy_heart()
		print("heart?")
		mode_at_swing = controller.Mode.DEMISE

func exit_mood() -> void:
	print("Exited Joy mood!")
	# Remove double jump
	controller.hp_manager.remove_joy_heart()
	controller.change_jump_count(1)

func get_multipliers() -> Dictionary:
	# Check which mode we're in
	if controller.current_mode_type == controller.Mode.DEMIDEVIL:
		return {
			"attack": 0.9,   # Slightly lower attack (unfocused)
			"defense": 1.0,
			"speed": 1.2     # +20% movement speed (euphoric, bouncy)
		}
	else:  # DEMISE
		return {
			"attack": 1.0,
			"defense": 1.0,
			"speed": 1.0     # Normal movement, contentment provides resilience
		}
		
func process_mood(delta: float) -> void:
	if controller.current_mode_type == mode_at_swing:
		pass
	else:
		enter_mood()
