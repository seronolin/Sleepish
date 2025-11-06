# ModeBase.gd
extends Node2D
class_name ModeBase

const PHYSICS_MULTIPLIER := 50

@export var controller: PlayerController
@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer
@export var state_machine: StateMachine

@export var max_speed_raw := 3.0
@export var acceleration_raw := 10.0
@export var deceleration_raw := 10.0
@export var jump_force_raw := 2.0
@export var gravity_raw := 9.8

var max_speed: float
var acceleration: float
var deceleration: float
var jump_force: float
var gravity: float

## Feel parameters
@export var jump_buffer_time = 0.1
@export var jump_count := 1

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_ground: bool = false

var dash_available: bool = true
var glide_charge: float = 1.0  # Full charge (normalized 0.0 to 1.0)
var facing_direction: int = 1  # 1 for right, -1 for left

func init_physics():
	# Get mood multipliers
	var mood_mults = {"attack": 1.0, "defense": 1.0, "speed": 1.0}
	if controller and controller.mood_manager and controller.mood_manager.current_mood:
		mood_mults = controller.mood_manager.current_mood.get_multipliers()
	
	# Apply multipliers to physics values
	max_speed = max_speed_raw * PHYSICS_MULTIPLIER * mood_mults.speed
	acceleration = acceleration_raw * PHYSICS_MULTIPLIER * mood_mults.speed
	deceleration = deceleration_raw * PHYSICS_MULTIPLIER * mood_mults.speed
	jump_force = jump_force_raw * PHYSICS_MULTIPLIER
	gravity = gravity_raw * PHYSICS_MULTIPLIER
	
	print("Physics initialized - Speed multiplier: ", mood_mults.speed)
	print("Final max_speed: ", max_speed)
	print("Physics initialized - Speed multiplier: ", mood_mults.speed)

func _process(delta):
	## Flip character sprite
	if controller.direction > 0:
		sprite.flip_h = false
	elif controller.direction < 0: 
		sprite.flip_h = true

func enter():
	visible = true
	sprite.visible = true
	set_process(true)
	init_physics()

func exit():
	visible = false
	sprite.visible = false
	set_process(false)

func update_movement_timers(delta: float):
	# Coyote time logic
	if controller.is_on_floor():
		coyote_timer = controller.coyote_time
		
		# Reset dash/glide charges when landing
		if not was_on_ground:  # Just landed this frame
			dash_available = true
			glide_charge = 1.0
			controller.jumps_used = 0
		was_on_ground = true
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		was_on_ground = false
	#print (controller.jumps_used)
	#print (self.jump_count)
	#print(controller.can_jump())
	#print (controller.is_on_floor())
	#print (coyote_timer)

	# Jump buffer timer
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

## Helper functions
func can_jump() -> bool:
	return controller.is_on_floor() or coyote_timer > 0.0

func execute_jump():
	controller.velocity.y = -jump_force
	coyote_timer = 0.0  # Used up coyote time
	jump_buffer_timer = 0.0  # Used up jump buffer

func play_animation(animation: StringName):
	animation_player.play(animation)
