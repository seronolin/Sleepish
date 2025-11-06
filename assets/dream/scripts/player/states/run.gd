extends State

func enter_state():
	controller.current_form.play_animation("run")

func update_logic(delta: float):
	# First, handle airborne transition
	if not controller.is_on_floor():
		state_machine.change_state(state_machine.fall)
		return

	# Get input direction
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	# No input: decelerate toward 0
	if input_direction == 0:
		controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_form.deceleration * delta)

		if abs(controller.velocity.x) < 1:
			controller.velocity.x = 0
			state_machine.change_state(state_machine.idle)
			return

	# Input present: accelerate toward target speed
	else:
		var target_speed: float = input_direction * controller.current_form.max_speed
		controller.velocity.x = move_toward(controller.velocity.x, target_speed, controller.current_form.acceleration * delta)

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and controller.can_jump():
		state_machine.change_state(state_machine.jump)
