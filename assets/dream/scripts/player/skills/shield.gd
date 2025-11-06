## Shield Skill
## Demise + Sadness
## Activates the shield buff (via BuffManager)
extends Skill

func _ready() -> void:
	super._ready()
	
	## Configure skill properties
	skill_name = "Shield"
	cooldown_duration = 15.0  ## 15 second cooldown after shield breaks
	max_charges = 1  ## Cooldown-based, not charge-based

## Execute: Tell BuffManager to activate shield
func execute() -> void:
	var buff_manager = player.get_node_or_null("BuffManager")
	
	if not buff_manager:
		push_error("Shield skill: BuffManager not found!")
		return
	
	## Activate 3-hit shield via BuffManager
	buff_manager.add_shield(3)
	print("🛡 Shield skill used - 3-hit shield activated!")

## The shield buff itself handles the hit blocking logic
## This skill just activates it
