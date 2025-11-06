# active_effect.gd
# Tracks a single active effect on the player
class_name ActiveEffect

var effect_name: String
var data: BiteBlightData
var time_remaining: float
var is_permanent: bool  # "Until Rest" effects

# Stat modifiers this effect applied
var applied_atk: float = 1.0
var applied_def: float = 1.0
var applied_speed: float = 1.0

# Custom effect instance (if any)
var custom_effect: BiteBlightEffect = null

# Visual/UI data
var icon: Texture2D

func _init(p_name: String, p_data: BiteBlightData):
	effect_name = p_name
	data = p_data
	icon = p_data.icon
	
	# Determine duration type
	if data.duration < 0:
		is_permanent = true
		time_remaining = -1
	else:
		is_permanent = false
		time_remaining = data.duration
	
	# Store what stat changes this effect applied
	applied_atk = data.atk_multiplier
	applied_def = data.def_multiplier
	applied_speed = data.speed_multiplier

func update(delta: float) -> bool:
	if is_permanent:
		return false  # Don't expire
	
	if time_remaining <= 0:
		return false
	
	time_remaining -= delta
	
	# Update custom effect if it exists
	if custom_effect:
		custom_effect.update(delta)
	
	return time_remaining > 0

func cleanup(player):
	# Let custom effect clean up
	if custom_effect:
		custom_effect.on_end(player)
