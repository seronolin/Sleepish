extends Control

@onready var label := $Label

func _ready() -> void:
	if GameClock.current_day == 0 :
		label.text = "??:??"

func _process(_delta):
	if GameClock:
		label.text = "Day %d - %02d:%02d" % [
			GameClock.current_day,
			GameClock.current_hour,
			GameClock.current_min
		]
