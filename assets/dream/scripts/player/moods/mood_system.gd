class_name MoodManager extends Node

var controller: PlayerController
var current_mood: Mood
var current_mood_name := ""

@onready var joy = $Joy
@onready var sadness = $Sadness
@onready var anger = $Anger
@onready var neutral = $Neutral

signal mood_updated(mood:String)

func _ready() -> void:
	controller = get_parent()  # MoodManager is child of Player
	
	# Give all mood nodes their references
	for mood in get_children():
		mood.mood_manager = self
		mood.controller = controller
	# Start in neutral mood
	set_mood(neutral)
	
	#print("MoodManager ready!")

func _process(delta: float) -> void:
	if current_mood:
		current_mood.process_mood(delta)

func set_mood(new_mood: Mood) -> void:
	# Exit current mood if there is one
	if current_mood:
		current_mood.exit_mood()
	
	# Enter new mood
	current_mood = new_mood
	current_mood.enter_mood()
	
	match current_mood:
		joy : 
			current_mood_name = "Joy"
		sadness : 
			current_mood_name = "Sadness"
		anger : 
			current_mood_name = "Anger"
		neutral : 
			current_mood_name = "Neutral"
	
	mood_updated.emit(current_mood_name)
	
	# Update mode physics with new multipliers
	if controller.current_mode:
		controller.current_mode.init_physics()

## take this out later
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				set_mood(joy)
			KEY_2:
				set_mood(sadness)
			KEY_3:
				set_mood(anger)
			KEY_0:
				set_mood(neutral)


func _on_player_mode_changed() -> void:
	current_mood.exit_mood()
	current_mood.enter_mood()
