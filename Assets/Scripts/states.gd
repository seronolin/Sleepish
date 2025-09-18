class_name State extends Node


var state_machine: StateMachine
var controller: PlayerController
var form : FormBase

@export var can_move := false
@export var gravity_enabled := true

func enter_state():
	pass

func exit_state():
	pass

func update_logic(delta: float):
	pass

func handle_input(event: InputEvent):
	pass

func draw():
	pass
