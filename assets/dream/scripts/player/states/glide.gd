extends State

@export var glide_speed: float = 150.0  # Horizontal movement speed while gliding
@export var glide_fall_speed: float = 50.0  # Slow descent speed
@export var glide_max_time: float = 1.0  # Total glide time (adjust so distance matches dash)
@export var glide_timer: float = 0.0

func enter_state():
	gravity_enabled = false  # Disable gravity during glide
	glide_timer = controller.current_mode.glide_charge  # Use remaining glide charge
	controller.current_mode.play_animation("glide")

func update_logic(delta: float):
	# Drain the glide timer
	glide_timer -= delta
	controller.current_mode.glide_charge = glide_timer
	
	# Get input direction (allows mid-glide direction change)
	var input_x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	# Apply controlled horizontal movement
	if input_x != 0:
		controller.velocity.x = input_x * glide_speed
	else:
		# Decelerate if no input
		controller.velocity.x = move_toward(controller.velocity.x, 0, controller.current_mode.deceleration * delta)
	
	# Get vertical input
	var input_y := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Apply controlled vertical movement
	if input_y != 0:
		controller.velocity.y = input_y * glide_speed
	else:
		# Default slow fall when no vertical input
		controller.velocity.y = glide_fall_speed
	
	# Check for glide end conditions
	if glide_timer <= 0:
		# Out of glide charge
		controller.current_mode.glide_charge = 0.0
		state_machine.change_state(state_machine.fall)
		return
	
	if not Input.is_action_pressed("right_click"):
		# Player released the glide button
		state_machine.change_state(state_machine.fall)
		return
	
	if controller.is_on_floor():
		# Landed while gliding
		state_machine.change_state(state_machine.idle)
		return

func handle_input(event: InputEvent):
	# Allow jumping out of glide
	if event.is_action_pressed("jump") and controller.can_jump():
		state_machine.change_state(state_machine.jump)

func exit_state():
	gravity_enabled = true  # Re-enable gravity when leaving glide
