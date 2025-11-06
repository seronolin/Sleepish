## Shield Buff
## Blocks a certain number of hits before breaking
extends Buff

## Shield state
var hits_remaining: int = 0
var max_hits: int = 0

## Signals
signal shield_hit_consumed(hits_left: int)
signal shield_broken

func _ready() -> void:
	super._ready()
	buff_name = "Shield"

## Called when shield is first applied or refreshed
func initialize(params: Dictionary) -> void:
	if params.has("hits"):
		max_hits = params["hits"]
		hits_remaining = max_hits
	else:
		push_warning("ShieldBuff: No 'hits' parameter provided, defaulting to 3")
		max_hits = 3
		hits_remaining = 3

## Called when shield activates
func on_activate() -> void:
	print("🛡 Shield activated with ", hits_remaining, " hits")
	## TODO: Show shield visual (sprite, particle effect, etc.)
	_show_visual()

## Called when shield deactivates
func on_deactivate() -> void:
	hits_remaining = 0
	print("Shield deactivated")
	## TODO: Hide shield visual
	_hide_visual()

## Consume one hit from the shield
## Returns true if damage was blocked, false if shield is depleted
func consume_hit() -> bool:
	if hits_remaining <= 0:
		return false  ## Shield already broken
	
	hits_remaining -= 1
	shield_hit_consumed.emit(hits_remaining)
	print("🛡 Shield blocked hit! (", hits_remaining, " hits remaining)")
	
	## Check if shield broke
	if hits_remaining <= 0:
		print("💔 Shield shattered!")
		shield_broken.emit()
		buff_consumed.emit()  ## Tell BuffManager to deactivate this buff
		return true  ## Still blocked this final hit
	
	return true  ## Damage blocked

## Get current hits remaining (for UI)
func get_hits_remaining() -> int:
	return hits_remaining

## Get max hits (for UI)
func get_max_hits() -> int:
	return max_hits

## Show shield visual effect
func _show_visual() -> void:
	#TODO: When you add a Sprite2D or AnimatedSprite2D child node, show it here
	# Example:
	if has_node("ShieldSprite"):
		$ShieldSprite.visible = true
	pass

## Hide shield visual effect
func _hide_visual() -> void:
	## TODO: Hide visual when shield breaks
	## Example:
	# if has_node("ShieldSprite"):
	# 	$ShieldSprite.visible = false
	pass
