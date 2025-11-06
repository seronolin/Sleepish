# dream_region_base.gd
extends Node2D

@onready var spawn_point: Marker2D = $PlayerSpawnPoint

func _ready() -> void:
	# DO NOT spawn player here - GameManager handles that
	# This script only provides spawn point data
	print("[DreamRegion] Ready, spawn point at: ", get_spawn_position())

func get_spawn_position() -> Vector2:
	return spawn_point.global_position if spawn_point else Vector2(100, 100)
