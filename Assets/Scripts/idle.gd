extends State
func enter_state():
	controller.current_form.play_animation("idle")

func update_logic(delta: float):
	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if not controller.is_on_floor():
		state_machine.change_state(state_machine.fall)
	if input_direction != 0:
		state_machine.change_state(state_machine.run)

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and controller.can_jump():
		state_machine.change_state(state_machine.jump)
