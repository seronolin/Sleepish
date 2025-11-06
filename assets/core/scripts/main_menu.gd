# main_menu.gd
extends Control

@onready var start_button = $StartButton

func _ready():
	start_button.text = "Start Game"
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	print("[MainMenu] Starting game...")
	# Boot directly into dream
	GameManager.call_deferred("load_dream_region", "castle_in_the_sky", Vector2(100, 100))
	# Remove main menu from scene tree after starting game
	queue_free()
