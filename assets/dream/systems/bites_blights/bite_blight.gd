# bite_blight.gd
@tool  # This makes it run in the editor!
extends Area2D

@export var data: BiteBlightData:
	set(value):
		data = value
		_update_sprite()

# Float animation settings
@export var float_height: float = 8.0  # How high/low it bobs
@export var float_speed: float = 2.0   # How fast it bobs

var time: float = 0.0
var start_y: float = 0.0

func _ready():
	_update_sprite()
	
	# Don't run gameplay code in editor
	if Engine.is_editor_hint():
		return
	
	# Setup collision
	collision_layer = 0
	collision_mask = 1  # Only detect player
	
	# Store starting position for floating
	start_y = position.y
	
	# Random offset so not all pickups bob in sync
	time = randf() * TAU
	
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Don't animate in editor
	if Engine.is_editor_hint():
		return
	
	# Bob up and down (only upward from starting position)
	time += delta * float_speed
	var offset = (sin(time) + 1.0) / 2.0  # Converts -1..1 to 0..1
	position.y = start_y - (offset * float_height)

func _update_sprite():
	if not is_inside_tree():
		return
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite and data and data.icon:
		sprite.texture = data.icon

func _on_body_entered(body):
	if body.is_in_group("player") and data:
		# Apply the effect
		BiteBlightManager.apply_powerup(body, data)
		
		# Register in glossary
		GlossaryManager.register_discovered(data)
		
		# TODO: Play pickup sound/effect
		
		# Remove powerup
		queue_free()
