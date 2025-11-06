extends Control

# References to your components
@onready var bar_background: Sprite2D = $BarBackground
@onready var bar_fill: NinePatchRect = $BarFill
@onready var bar_frame: Sprite2D = $BarFrame
@onready var threshold_arrows: Sprite2D = $ThresholdArrows

# Bar fill settings
var bar_fill_max_width: float = 0.0
var bar_start_x: float = 0.0

func _ready():
	# Store the original bar width for calculations
	# Account for NinePatchRect patch margins - the actual fillable area
	bar_fill_max_width = bar_fill.size.x - bar_fill.patch_margin_left - bar_fill.patch_margin_right
	# Start position is the NinePatchRect position plus the left margin
	bar_start_x = bar_fill.position.x + bar_fill.patch_margin_left
	
	# Get player from group and connect to energy signal
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.energy_changed.connect(_on_energy_changed)
		# Initial update with current values
		_on_energy_changed(player.energy, player.max_energy, player.min_energy, player.energy_threshold)
	
	print("Bar fill max width: ", bar_fill_max_width)
	print("Bar start x: ", bar_start_x)
	print("Patch margins - Left: ", bar_fill.patch_margin_left, " Right: ", bar_fill.patch_margin_right)

func _on_energy_changed(current: int, maximum: int, minimum: int, threshold: int):
	print("Energy changed - Current: ", current, " Max: ", maximum, " Threshold: ", threshold)
	update_bar(current, maximum, threshold)
	position_threshold_arrows(threshold, maximum)

func update_bar(current_energy: int, max_energy: int, threshold: int):
	# Calculate fill percentage
	var fill_percentage = float(current_energy) / float(max_energy)
	
	# Update the bar fill by changing its width
	# NinePatchRect will preserve the ends and stretch/shrink the middle
	var new_width = bar_fill_max_width * fill_percentage
	bar_fill.size.x = new_width
	
	# Optional: Change color based on energy level
	#if current_energy < threshold:
		## Demise state - could tint bar or change modulation
		#bar_fill.modulate = Color(0.7, 0.7, 1.0) # Slight blue tint
	#else:
		## Demidevil state - could tint bar differently
		#bar_fill.modulate = Color(1.0, 0.7, 0.7) # Slight red tint

func position_threshold_arrows(threshold: int, max_energy: int):
	# Calculate where the threshold sits on the bar
	var threshold_percentage = float(threshold) / float(max_energy)
	
	# Position arrows at the threshold
	# The bar fill position is where it starts, plus the offset for the threshold
	var threshold_x = bar_start_x + (bar_fill_max_width * threshold_percentage)
	threshold_arrows.position.x = threshold_x
	
	# Position arrows above or overlapping the bar
	# Adjust this based on your layout
	threshold_arrows.position.y = bar_fill.position.y - 10

# Example animation for when bottled anger is active
func show_bottled_anger_warning():
	# Pulse the bar or add visual effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(bar_frame, "modulate", Color.RED, 0.5)
	tween.tween_property(bar_frame, "modulate", Color.WHITE, 0.5)

func stop_bottled_anger_warning():
	bar_frame.modulate = Color.WHITE
