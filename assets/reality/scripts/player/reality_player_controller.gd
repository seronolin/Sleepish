extends CharacterBody2D
class_name RealityPlayerController

enum Direction {UP, DOWN, LEFT, RIGHT}
var current_direction = Direction.DOWN
var input_x = Input.get_axis("move_left", "move_right")
var input_y = Input.get_axis("move_up", "move_down")

const MIN_ENERGY: int = 0
const MAX_ENERGY: int = 100
const MIN_STAMINA: int = 0
const MAX_STAMINA: int = 9
const MIN_HUNGER: int = 0
const MAX_HUNGER: int = 100

@export var current_energy: int = 90
@export var current_stamina: int
@export var current_hunger: int
@export var sleep_treshold: int = 21

@export var sluggish_walk_spd := 69
@export var normal_walk_spd := 90
@export var run_spd := 150

var current_speed :int

@onready var sprite: Sprite2D
@onready var animation_player: AnimationPlayer

func _physics_process(delta):
	# Get input
	var input_vector = Vector2()
	input_vector.x = Input.get_axis("move_left", "move_right")  # -1 to 1
	input_vector.y = Input.get_axis("move_up", "move_down")    # -1 to 1
	
	# Only update facing direction when actually moving?
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			# Moving more horizontally
			if input_vector.x > 0:
				current_direction = Direction.RIGHT
			else:
				current_direction = Direction.LEFT
		else:
			# Moving more vertically  
			if input_vector.y > 0:
				current_direction = Direction.DOWN
			else:
				current_direction = Direction.UP
	
	# Calculate current speed
	assign_current_speed()
	
	# Apply movement to velocity
	velocity = input_vector * current_speed
	
	# Call move_and_slide()
	move_and_slide()
	
	# TODO: Update animations based on direction, probably going to be a separate function called here? idk
	

func assign_current_speed():
	if current_energy >= 30:
		current_speed = normal_walk_spd
		if Input.is_action_pressed("dash") && current_stamina >= 3:
			current_speed = run_spd
			# TODO: Drain stamina over time
	else:
		current_speed = sluggish_walk_spd

func update_animations():
	match current_direction:
		Direction.DOWN:
			animation_player.play("walk_down") 
		Direction.UP:
			animation_player.play("walk_up")
		Direction.RIGHT:
			sprite.flip_h = false
			animation_player.play("walk")
		Direction.LEFT:
			sprite.flip_h = true
			animation_player.play("walk")

func get_energy() -> float:
	return current_energy
func change_energy(amount:float):
	current_energy = max(0.0, current_energy - amount)
	# Check for pass-out
	if current_energy <= 0.0:
		pass_out()

func pass_out():
	pass
	#TODO: add passout logic?
