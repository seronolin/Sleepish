extends Mood

func enter_mood() -> void:
	print("Demi feels neutral")

func exit_mood() -> void:
	print("Demi is no longer neutral")

func process_mood(delta: float) -> void:
	pass  # We'll add logic later
