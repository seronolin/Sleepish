# bite_blight_effect.gd
# Base class for custom bite/blight effects
# Inherit from this to create complex, unique effects
class_name BiteBlightEffect

var data: BiteBlightData
var player: Node

func _init(p_player: Node, p_data: BiteBlightData):
	player = p_player
	data = p_data

# Called when effect is first applied
func on_start():
	pass

# Called every frame while active (if effect has duration)
func update(delta: float):
	pass

# Called when effect ends (duration expires or manually removed)
func on_end(p_player: Node):
	pass

# Called when player rests (for "Until Rest" effects)
func on_rest(p_player: Node):
	pass
