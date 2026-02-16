extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	Global.resume_game()


func _on_wake_up_pressed() -> void:
	SceneManager.switch_world()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	pass # Replace with function body.
