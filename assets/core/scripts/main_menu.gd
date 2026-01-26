# main_menu.gd
extends Control

@onready var start_button = $StartButton

func _ready():
	start_button.text = "Start Game"
	start_button.pressed.connect(_on_start_pressed)
	SceneManager.current_gui_node = self

func _on_start_pressed():
	print("[MainMenu] Starting game...")
	SceneManager.change_live_scene(SceneManager.World.REALITY,"demis_bedroom", SceneManager.ChangeOptions.DELETE)
	SceneManager.change_gui_scene( "res://assets/reality/scenes/ui/reality_hud.tscn", SceneManager.ChangeOptions.DELETE)
