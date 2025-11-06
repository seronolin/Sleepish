extends CanvasLayer

@export var player :PlayerController

@onready var health_bar = $MarginContainer/HBoxContainer/HealthDisplay
@onready var energy_bar = $"MarginContainer/HBoxContainer/EnergyBar"
@onready var mood_label = $"MoodLabel"

func _ready():
	pass

func update_energy(energy, max_energy, min_energy, energy_threshold):
	energy_bar.set_bar_values(energy, max_energy, min_energy, energy_threshold)

func update_mood_display():
	if not player or not player.mood_manager or not player.mood_manager.current_mood:
		return
	
	var mood_name = "Unknown"
	var mood = player.mood_manager.current_mood
	
	if mood == player.mood_manager.neutral:
		mood_name = "Neutral"
	elif mood == player.mood_manager.joy:
		mood_name = "Joy"
	elif mood == player.mood_manager.sadness:
		mood_name = "Sadness"
	elif mood == player.mood_manager.anger:
		mood_name = "Anger"
	
	mood_label.text = "Mood: " + mood_name
