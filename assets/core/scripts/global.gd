extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		else:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		if get_tree().paused:
			resume_game()
		else:
			open_pause_menu()

func open_pause_menu() -> void:
	GameClock.stop_clock()
	get_tree().paused = true
	
	if SceneManager.current_world == SceneManager.World.REALITY:
		SceneManager.change_gui_scene("res://assets/reality/scenes/ui/reality_pause.tscn", SceneManager.ChangeOptions.HIDE)
	else:  # DREAM
		SceneManager.change_gui_scene("res://assets/dream/scenes/ui/dream_pause.tscn", SceneManager.ChangeOptions.HIDE)

func resume_game() -> void:
	get_tree().paused = false
	GameClock.start_clock()
	if SceneManager.current_world == SceneManager.World.REALITY:
		SceneManager.change_gui_scene("res://assets/reality/scenes/ui/reality_hud.tscn", SceneManager.ChangeOptions.DELETE)
	else:  # DREAM
		SceneManager.change_gui_scene("res://assets/dream/scenes/ui/dream_hud.tscn", SceneManager.ChangeOptions.DELETE)
