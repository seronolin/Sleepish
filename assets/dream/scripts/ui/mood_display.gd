extends AnimatedSprite2D

var active_mood_displayed

enum Moods {
	JOY,
	SADNESS,
	ANGER
	}

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("MoodManager"):
		var mood_manager = player.get_node("MoodManager")
		mood_manager.mood_updated.connect(_on_mood_updated)
		self.play(mood_manager.current_mood_name)
		


func _on_mood_updated(current_mood):
	self.play(current_mood)
	active_mood_displayed = current_mood
