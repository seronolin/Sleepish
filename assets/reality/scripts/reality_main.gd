extends Node2D

@onready var reality_player = $RealityPlayer  # Adjust path if needed

func _ready() -> void:
	print("[RealityMain] Scene loaded")
	GameManager.current_world = self

func get_player_position() -> Vector2:
	if reality_player:
		return reality_player.global_position
	return Vector2.ZERO
