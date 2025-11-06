# states/dead.gd
extends State

var hp_manager: HPManager

func enter_state():
	print("Entered Death State")
	hp_manager = controller.hp_manager
	
	# Stop player movement
	controller.velocity = Vector2.ZERO
	
	# Check for revives
	if hp_manager.has_revives():
		# Has revives, play brief death then go to reviving
		_play_death_animation()
		await get_tree().create_timer(0.5).timeout  # Brief pause
		state_machine.change_state(state_machine.reviving)
	else:
		# No revives, full death
		_play_death_animation()
		await get_tree().create_timer(2.0).timeout  # Longer death animation
		_handle_game_over()

func _play_death_animation():
	print("Playing death animation")
	# TODO: Play actual death animation when you have AnimationPlayer set up
	# controller.get_node("AnimationPlayer").play("death")

func _handle_game_over():
	print("Game Over!")
	# TODO: Implement game over logic
	# get_tree().reload_current_scene()
	# or show game over screen or like, emit a signal? idfk

func exit_state():
	pass

func update_logic(delta: float):
	# No physics/logic while dead
	pass

func handle_input(event: InputEvent):
	# No input while dead
	pass
