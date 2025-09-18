# FormBase.gd
extends Node2D
class_name FormBase

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
@export var coyote_time = 0.15
@export var jump_buffer_time = 0.1
@export var jump_count := 1

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_ground: bool = false

func init_physics():
	max_speed = max_speed_raw * PHYSICS_MULTIPLIER
	acceleration = acceleration_raw * PHYSICS_MULTIPLIER
	deceleration = deceleration_raw * PHYSICS_MULTIPLIER
	jump_force = jump_force_raw * PHYSICS_MULTIPLIER
	gravity = gravity_raw * PHYSICS_MULTIPLIER

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
		coyote_timer = coyote_time
		was_on_ground = true
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		was_on_ground = false
	
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
