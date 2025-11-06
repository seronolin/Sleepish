# states/reviving.gd
extends State

var hp_manager: HPManager

func enter_state():
	print("Entered Reviving State")
	hp_manager = controller.hp_manager
	
	# Consume the revive
	hp_manager.consume_revive()
	
	# Stop movement
	controller.velocity = Vector2.ZERO
	
	# Play revive animation
	_play_revive_animation()
	
	# Wait for animation
	await get_tree().create_timer(1.5).timeout
	
	# Return to idle
	state_machine.change_state(state_machine.idle)

func _play_revive_animation():
	print("Playing revive animation - halo appears!")
	# TODO: Play actual revive animation
	# Show halo if player has it
	if controller.has_node("Halo"):
		controller.get_node("Halo").visible = hp_manager.has_revives()

func exit_state():
	pass

func update_logic(delta: float):
	# Frozen during revive
	controller.velocity = Vector2.ZERO

func handle_input(event: InputEvent):
	# No input during revive
	pass
