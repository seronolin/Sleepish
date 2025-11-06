## Manages all active buffs/effects on the player
## Buffs are child nodes that exist in the scene, this just activates/deactivates them
extends Node

## References
@onready var player: PlayerController = get_parent()
var hp_manager: HPManager

## Buff references (set when buff nodes are added as children)
var shield_buff: Buff = null
var halo_buff: Buff = null

## Signals
signal buff_activated(buff_name: String)
signal buff_deactivated(buff_name: String)

func _ready() -> void:
	## Get references
	hp_manager = player.get_node_or_null("HpManager")
	
	if not hp_manager:
		push_error("BuffManager: HpManager not found!")
	
	## Find buff child nodes and set them up
	call_deferred("_setup_buffs")

func _setup_buffs() -> void:
	## Look for buff children and store references
	for child in get_children():
		if child is Buff:
			## Set up buff references
			child.player = player
			child.hp_manager = hp_manager
			child.buff_manager = self
			
			## Connect signals
			if child.has_signal("buff_consumed"):
				child.buff_consumed.connect(_on_buff_consumed.bind(child))
			
			## Store reference based on type
			match child.name:
				"ShieldBuff":
					shield_buff = child
				"HaloBuff":
					halo_buff = child
			
			print("BuffManager: Found buff - ", child.buff_name)

func _process(delta: float) -> void:
	## Update all active buffs
	for child in get_children():
		if child is Buff and child.is_active:
			child.process_buff(delta)

## Called when a buff is fully consumed/depleted
func _on_buff_consumed(buff: Buff) -> void:
	buff.deactivate()

## === SHIELD BUFF HELPERS ===

func add_shield(hits: int) -> void:
	if not shield_buff:
		push_warning("BuffManager: ShieldBuff node not found!")
		return
	
	shield_buff.initialize({"hits": hits})
	shield_buff.activate()

func has_shield() -> bool:
	return shield_buff and shield_buff.is_active

func consume_shield_hit() -> bool:
	if shield_buff and shield_buff.is_active and shield_buff.has_method("consume_hit"):
		return shield_buff.consume_hit()
	return false

## === HALO BUFF HELPERS ===

func add_halo() -> void:
	if not halo_buff:
		push_warning("BuffManager: HaloBuff node not found!")
		return
	
	halo_buff.initialize({})
	halo_buff.activate()

func has_halo() -> bool:
	return halo_buff and halo_buff.is_active

func consume_halo() -> bool:
	if halo_buff and halo_buff.is_active and halo_buff.has_method("consume_revive"):
		return halo_buff.consume_revive()
	return false

## Clear all buffs (useful for death, respawn, etc.)
func clear_all_buffs() -> void:
	for child in get_children():
		if child is Buff and child.is_active:
			child.deactivate()
