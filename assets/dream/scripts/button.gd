# test_button.gd
# This basically is the script attached to both the reality and dream hud buttons that is meant to switch between the worlds
extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	print("[Button] Clicked!")
	print("[Button] in_dream = ", GameManager.in_dream)
	print("[Button] is_in_reality = ", GameManager.is_in_reality())
	
	if GameManager.is_in_reality():
		print("[Button] Switching to Dream...")
		GameManager.initiate_sleep(true)
	else:
		print("[Button] Switching to Reality...")
		GameManager.initiate_wake()
