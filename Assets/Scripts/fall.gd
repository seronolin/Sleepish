extends State

func enter_state():
	controller.current_form.play_animation("fall")

func update_logic(delta: float):
	# Check for landing
	if controller.is_on_floor():
		state_machine.change_state(state_machine.idle)
		return
	
	# Handle horizontal air control (same as jump state)
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if input_direction == 0:
		# No input - decelerate horizontally
		controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_form.deceleration * delta)
	else:
		# Input detected - accelerate toward target speed
		var target_speed: float = input_direction * controller.current_form.max_speed
		controller.velocity.x = move_toward(controller.velocity.x, target_speed, controller.current_form.acceleration * delta)

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and controller.current_form.can_jump():
		state_machine.change_state(state_machine.jump)
