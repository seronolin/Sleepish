extends State

func enter_state():
	# Launch upward
	controller.velocity.y = -controller.current_form.jump_force
	controller.current_form.play_animation("jump")

func update_logic(delta):
	# Handle horizontal air control
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if input_direction == 0:
		# No input - decelerate horizontally
		controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_form.deceleration * delta)
	else:
		# Input detected - accelerate toward target speed
		var target_speed: float = input_direction * controller.current_form.max_speed
		controller.velocity.x = move_toward(controller.velocity.x, target_speed, controller.current_form.acceleration * delta)
	
	# Transition to fall when moving downward
	if controller.velocity.y > 0:
		state_machine.change_state(state_machine.fall)

func handle_input(event: InputEvent):
	pass # No double jumps for now
