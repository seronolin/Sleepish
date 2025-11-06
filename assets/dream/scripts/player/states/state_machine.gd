class_name StateMachine extends Node

@onready var idle:= $Idle
@onready var run:= $Run
@onready var jump:= $Jump
@onready var fall:= $Fall
@onready var dash:= $Dash
@onready var glide:= $Glide
@onready var dead:= $Dead
@onready var reviving:= $Reviving

@export var current_state: State


func _physics_process(delta: float) -> void:
#	var input_direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if current_state:
		current_state.update_logic(delta)

func change_state(new_state: State):
	if current_state is State:
		current_state.exit_state()
	
	new_state.controller = get_parent()
	new_state.mode = get_parent().current_mode
	new_state.state_machine = self

	new_state.enter_state()
	current_state = new_state


func _on_player_mode_changed() -> void:
	change_state(current_state)
