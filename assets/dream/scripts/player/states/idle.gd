extends State

func enter_state():
	controller.current_mode.play_animation("idle")

func update_logic(delta: float):
	# Decelerate to stop sliding
	controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_mode.deceleration * delta)
	
	# Check for state transitions
	if not controller.is_on_floor():
		state_machine.change_state(state_machine.fall)
		return
	
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_direction != 0:
		state_machine.change_state(state_machine.run)

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and controller.can_jump():
		state_machine.change_state(state_machine.jump)
		
	if event.is_action_pressed("dash"):
		if controller.current_mode_type == controller.Mode.DEMIDEVIL and controller.current_mode.dash_available:
			state_machine.change_state(state_machine.dash)
		elif controller.current_mode_type == controller.Mode.DEMISE and controller.current_mode.glide_charge > 0:
			state_machine.change_state(state_machine.glide)
