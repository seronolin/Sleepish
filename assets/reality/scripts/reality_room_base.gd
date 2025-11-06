# reality_room_base.gd
extends Node2D

@onready var spawn_point: Marker2D = $PlayerSpawnPoint

func _ready() -> void:
	# Reposition player to spawn point if it exists
	var player = get_node_or_null("reality_player")
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func get_spawn_position() -> Vector2:
	if spawn_point:
		return spawn_point.global_position
	return Vector2(320, 180)  # Default fallback
