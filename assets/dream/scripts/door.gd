# door.gd
extends Area2D

@export var target_room: String = ""
@export var spawn_position: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Check if it's actually a player (CharacterBody2D)
	if body is CharacterBody2D:
		print("[Door] Triggering transition to: ", target_room)
		
		if GameManager.is_in_reality():
			GameManager.load_reality_room(target_room, spawn_position)
		else:
			GameManager.load_dream_region(target_room, spawn_position)
