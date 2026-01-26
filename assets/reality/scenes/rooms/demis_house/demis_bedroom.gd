extends Node2D

func _ready() -> void:
	GameClock.start_clock()
	GameClock.change_time(14,23)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
