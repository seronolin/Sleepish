## Base class for all buffs/effects
## All individual buffs inherit from this
class_name Buff
extends Node

## Buff properties
@export var buff_name: String = "Unnamed Buff"
@export var is_active: bool = false

## References (set by BuffManager)
var player: PlayerController
var hp_manager: HPManager
var buff_manager: Node

## Signals
signal buff_activated
signal buff_deactivated
signal buff_consumed  ## When a buff is used up (like shield breaking)

func _ready() -> void:
	pass

## Called when buff is first applied
func activate() -> void:
	if is_active:
		return  ## Already active
	
	is_active = true
	on_activate()
	buff_activated.emit()
	print("✓ ", buff_name, " activated")

## Called when buff ends/is removed
func deactivate() -> void:
	if not is_active:
		return
	
	is_active = false
	on_deactivate()
	buff_deactivated.emit()
	print("✗ ", buff_name, " deactivated")

## OVERRIDE in child classes - what happens when buff activates
func on_activate() -> void:
	pass

## OVERRIDE in child classes - what happens when buff ends
func on_deactivate() -> void:
	pass

## OVERRIDE in child classes - custom buff logic per frame (if needed)
func process_buff(delta: float) -> void:
	pass

## Check if this buff is currently active
func is_buff_active() -> bool:
	return is_active
