extends CharacterBody2D
class_name PlayerController

const DEFAULT_ENERGY_THRESHOLD: int = 50
const MIN_ENERGY: int = 0
const MAX_ENERGY: int = 100

@export var current_energy: int = 100
@export var energy_threshold: int = DEFAULT_ENERGY_THRESHOLD
@export var coyote_time: float = 0.0

@onready var demidevil = $Demidevil
@onready var demise = $Demise
@onready var state_machine = $"State Machine"

var direction := 0.0

enum Form { DEMISE, DEMIDEVIL }

var current_form: Node2D
var current_form_type = Form.DEMISE

func _ready():
	demise.controller = self
	demidevil.controller = self

	# Set starting form
	if current_energy > energy_threshold:
		switch_form(Form.DEMIDEVIL)
	else:
		switch_form(Form.DEMISE)

	state_machine.change_state(state_machine.idle)

func switch_form(form: Form):
	if current_form and current_form.has_method("exit"):
		current_form.exit()

	match form:
		Form.DEMIDEVIL:
			current_form = demidevil
		Form.DEMISE:
			current_form = demise

	if current_form.has_method("enter"):
		current_form.enter()

	current_form_type = form
	print("Form switched to: ", current_form_type)

func _physics_process(delta: float) -> void:
	# Auto-switch form based on energy
	if current_energy > energy_threshold and current_form_type != Form.DEMIDEVIL:
		switch_form(Form.DEMIDEVIL)
	elif current_energy < energy_threshold and current_form_type != Form.DEMISE:
		switch_form(Form.DEMISE)

	# Input axis (-1 to 1)
	direction = Input.get_axis("move_left", "move_right")

	# Apply gravity if current state allows it
	if state_machine.current_state and state_machine.current_state.gravity_enabled:
		if not is_on_floor():
			velocity.y += current_form.gravity * delta

	# State machine logic
	state_machine._physics_process(delta)

	# Apply movement
	move_and_slide()

func _input(event: InputEvent) -> void:
	if state_machine.current_state:
		state_machine.current_state.handle_input(event)

func can_jump() -> bool:
	# Simple coyote time support
	return is_on_floor() or coyote_time > 0.0
