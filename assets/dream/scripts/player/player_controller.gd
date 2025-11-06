class_name PlayerController extends CharacterBody2D

#signals
signal energy_changed(current, maximum, minimum, threshold)
signal health_changed(current, maximum)  # Keep for backwards compatibility
signal mode_changed()
#Energy constants
const DEFAULT_ENERGY_THRESHOLD: int = 50
const DEFAULT_MIN_ENERGY: int = 0
const DEFAULT_MAX_ENERGY: int = 100

@export var energy: int = 100
@export var max_energy: int = 100
@export var min_energy: int = 0
@export var energy_threshold: int = DEFAULT_ENERGY_THRESHOLD
@export var coyote_time: float = 0.15

@onready var demidevil = $Demidevil
@onready var demise = $Demise
@onready var state_machine = $StateMachine
@onready var mood_manager = $MoodManager
@onready var hp_manager = $HpManager

enum Mode { DEMISE, DEMIDEVIL }
var current_mode: Node2D
var current_mode_type = Mode.DEMISE
var direction := 0.0
var jumps_used :int = 0

#stat multipliers
var atk_multiplier = 1.0
var def_multiplier = 1.0
var healing_multiplier = 1.0
var hurting_multiplier = 1.0

func _ready():
	demise.controller = self
	demidevil.controller = self
	
	# Set starting mode
	if energy > energy_threshold:
		switch_mode(Mode.DEMIDEVIL)
	else:
		switch_mode(Mode.DEMISE)
	state_machine.change_state(state_machine.idle)
	
	add_to_group("player")
	
	# Connect HPManager's signals - with safety check
	if hp_manager:
		hp_manager.health_changed.connect(_on_hp_changed)
		hp_manager.player_died.connect(_on_died)
	else:
		push_error("HPManager node not found!")
	
	hp_manager.player_died.connect(_on_died)
	
	# Emit initial energy
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

func _on_hp_changed(current: int, maximum: int):
	# Forward HPManager's signal as PlayerController's signal
	# This keeps any existing systems that listen to player.health_changed working
	health_changed.emit(current, maximum)

func _on_died():
	# Force transition to death state when HP reaches 0
	state_machine.change_state(state_machine.dead)

func switch_mode(mode: Mode):
	if current_mode and current_mode.has_method("exit"):
		current_mode.exit()
	match mode:
		Mode.DEMIDEVIL:
			current_mode = demidevil
		Mode.DEMISE:
			current_mode = demise
	if current_mode.has_method("enter"):
		current_mode.enter()
	current_mode_type = mode
	mode_changed.emit()
	print("Mode switched to: ", current_mode_type)

func _physics_process(delta: float) -> void:
	current_mode.update_movement_timers(delta)
	
	# Auto-switch mode based on energy
	if energy > energy_threshold and current_mode_type != Mode.DEMIDEVIL:
		switch_mode(Mode.DEMIDEVIL)
	elif energy < energy_threshold and current_mode_type != Mode.DEMISE:
		switch_mode(Mode.DEMISE)
	
	
	direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		current_mode.facing_direction = sign(direction)
	
	if state_machine.current_state and state_machine.current_state.gravity_enabled:
		if not is_on_floor():
			velocity.y += current_mode.gravity * delta
	
	state_machine._physics_process(delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if state_machine.current_state:
		state_machine.current_state.handle_input(event)
		
	# CHANGED: Now calls HPManager instead
	if event.is_action_pressed("ui_down"):  
		hp_manager.take_damage(1)
	if event.is_action_pressed("ui_up"): 
		hp_manager.heal(1)

func can_jump() -> bool:
	return is_on_floor() or current_mode.jump_count > jumps_used or current_mode.coyote_timer > 0.00

func change_energy(amount: int):
	energy += amount
	energy = clamp(energy, min_energy, max_energy)
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

func change_energy_threshold(amount: int):
	energy_threshold += amount
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

# State locking functions
func lock_state_demidevil():
	min_energy = energy_threshold
	if energy < min_energy:
		energy = min_energy
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

func lock_state_demise():
	max_energy = energy_threshold
	if energy > max_energy:
		energy = max_energy
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

func unlock_state():
	min_energy = DEFAULT_MIN_ENERGY
	max_energy = DEFAULT_MAX_ENERGY
	energy_changed.emit(energy, max_energy, min_energy, energy_threshold)

func force_mode(mode_name: String):
	match mode_name:
		"Demidevil":
			change_energy_threshold(energy - 3)
		"Demise":
			change_energy_threshold(energy + 3)
	print("Forced mode: ", mode_name)

func force_mood(mood_name: String):
	print("Forcing mood: ", mood_name)

func enable_double_dash(duration: float):
	print("Double dash enabled for ", duration, " seconds")

func add_revive_effect():
	hp_manager.add_revive()

func add_shield_effect(count:int):
	hp_manager.add_shields(count)

func add_jitter_effect(duration: float):
	print("Jittery movement for ", duration, " seconds")

func extend_glide_time(duration: float):
	print("Extended glide for ", duration, " seconds")
	
func change_jump_count(count: int):
	current_mode.jump_count = count
	#print("can now jump", count, " times")
