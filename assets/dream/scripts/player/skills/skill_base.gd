## Base class for all skills
## All individual skills inherit from this
class_name Skill
extends Node

## Skill configuration (set in child classes)
@export var skill_name: String = "Unnamed Skill"
@export var cooldown_duration: float = 10.0
@export var max_charges: int = 1  ## 1 = cooldown-based, >1 = charge-based

## State tracking
var current_charges: int = 0
var cooldown_timer: float = 0.0
var is_active: bool = false  ## For skills with duration (shields, buffs, etc)
var active_timer: float = 0.0

## References (set by SkillManager when skill is added)
var player: CharacterBody2D
var hp_manager: Node
var mood_manager: Node

## Signals for UI and other systems
signal skill_executed
signal skill_ended
signal cooldown_complete
signal charge_restored

func _ready() -> void:
	## Start with full charges
	current_charges = max_charges

func _process(delta: float) -> void:
	## Update cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0.0
			_on_cooldown_complete()
	
	## Update active duration (for skills that last over time)
	if is_active and active_timer > 0:
		active_timer -= delta
		if active_timer <= 0:
			end_skill()

## Check if skill can be executed right now
func can_execute() -> bool:
	## Charge-based: need at least 1 charge and not currently active
	if max_charges > 1:
		return current_charges > 0 and not is_active
	## Cooldown-based: cooldown must be finished and not currently active
	else:
		return cooldown_timer <= 0 and not is_active

## Try to execute the skill (called when E is pressed)
func try_execute() -> bool:
	if not can_execute():
		return false
	
	## Execute the skill (implemented by child classes)
	execute()
	
	## Handle charges/cooldown
	if max_charges > 1:
		## Charge-based: consume a charge
		current_charges -= 1
		## If out of charges, start recharge timer
		if current_charges == 0:
			cooldown_timer = cooldown_duration
	else:
		## Cooldown-based: start cooldown immediately
		cooldown_timer = cooldown_duration
	
	skill_executed.emit()
	return true

## OVERRIDE THIS in child classes - this is where skill logic goes
func execute() -> void:
	push_warning("Skill.execute() not implemented for: " + skill_name)

## OVERRIDE THIS if your skill needs cleanup when it ends
func end_skill() -> void:
	is_active = false
	active_timer = 0.0
	skill_ended.emit()

## Called when cooldown finishes
func _on_cooldown_complete() -> void:
	if max_charges > 1:
		## Charge-based: restore all charges
		current_charges = max_charges
		charge_restored.emit()
	cooldown_complete.emit()

## UI Helper: Get cooldown progress (0.0 = on cooldown, 1.0 = ready)
func get_cooldown_progress() -> float:
	if cooldown_duration <= 0:
		return 1.0
	return 1.0 - (cooldown_timer / cooldown_duration)

## UI Helper: Get remaining cooldown time in seconds
func get_cooldown_remaining() -> float:
	return cooldown_timer

## UI Helper: Get current charge count
func get_charges() -> int:
	return current_charges

## UI Helper: Get max charges
func get_max_charges() -> int:
	return max_charges

## Utility: Force reset skill (useful for testing or special game events)
func reset() -> void:
	current_charges = max_charges
	cooldown_timer = 0.0
	is_active = false
	active_timer = 0.0
