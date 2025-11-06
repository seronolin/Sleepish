extends State

func enter_state():
	# Launch upward
	controller.velocity.y = -controller.current_mode.jump_force
	controller.current_mode.play_animation("jump")
	controller.jumps_used += 1

func update_logic(delta):
	# Handle horizontal air control
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if input_direction == 0:
		# No input - decelerate horizontally
		controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_mode.deceleration * delta)
	else:
		# Input detected - accelerate toward target speed
		var target_speed: float = input_direction * controller.current_mode.max_speed
		controller.velocity.x = move_toward(controller.velocity.x, target_speed, controller.current_mode.acceleration * delta)
	
	# Transition to fall when moving downward
	if controller.velocity.y > 0:
		state_machine.change_state(state_machine.fall)

func handle_input(event: InputEvent):
	if event.is_action_pressed("dash"):
		if controller.current_mode_type == controller.Mode.DEMIDEVIL and controller.current_mode.dash_available:
			state_machine.change_state(state_machine.dash)
		elif controller.current_mode_type == controller.Mode.DEMISE and controller.current_mode.glide_charge > 0:
			state_machine.change_state(state_machine.glide)
	if event.is_action_pressed("jump") and controller.can_jump():
		state_machine.change_state(state_machine.jump)
