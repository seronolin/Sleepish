extends State

var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 600.0  # Adjust to taste
var dash_duration: float = 0.25  # How long the dash lasts
var dash_timer: float = 0.0

func enter_state():
	gravity_enabled = false
	# Lock in the dash direction based on current input
	var input_x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_y := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	dash_direction = Vector2(input_x, input_y).normalized()
	
	# If no input, dash in the direction the player is facing
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(controller.current_mode.facing_direction, 0)
	
	dash_timer = dash_duration
	controller.current_mode.dash_available = false  # Consume the dash charge
	controller.current_mode.play_animation("dash")  # Assuming you'll make this animation

func exit_state():
	gravity_enabled = true

func update_logic(delta: float):
	dash_timer -= delta
	
	# Apply locked dash velocity
	controller.velocity = dash_direction * dash_speed
	
	# Dash complete
	if dash_timer <= 0:
		# Transition based on whether we're airborne or grounded
		if controller.is_on_floor():
			state_machine.change_state(state_machine.idle)
		else:
			state_machine.change_state(state_machine.fall)

func handle_input(event: InputEvent):
	pass  # Dash cannot be cancelled or interrupted
