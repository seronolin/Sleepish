# health_display.gd
extends HBoxContainer

@onready var hearts: Array[AnimatedSprite2D] = [
	$HeartWrapper1/Heart1,
	$HeartWrapper2/Heart2,
	$HeartWrapper3/Heart3
]

var joy_heart_wrapper: Control = null
var joy_heart: AnimatedSprite2D = null
var extra_heart_wrappers: Array[Control] = []
var extra_hearts: Array[AnimatedSprite2D] = []

# Track heart types for animation purposes
enum HeartType {
	STANDARD,
	EXTRA,
	HEALING,
	BROKEN,
	JOY
}

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("HpManager"):
		var hp_manager = player.get_node("HpManager")
		hp_manager.health_changed.connect(_on_health_changed)
		hp_manager.extra_hearts_changed.connect(_on_extra_hearts_changed)
		hp_manager.joy_heart_changed.connect(_on_joy_heart_changed)
		hp_manager.heart_broken.connect(_on_heart_broken)
		
		# Initialize UI
		_on_health_changed(hp_manager.current_hp, hp_manager.get_max_hp())
		_on_extra_hearts_changed(hp_manager.extra_hp, hp_manager.max_extra_hp)
		_on_joy_heart_changed(hp_manager.joy_hp, hp_manager.max_joy_hp)

func _on_health_changed(current_hp: int, max_hp: int):
	var player = get_tree().get_first_node_in_group("player")
	var hp_manager = player.get_node("HpManager")
	
	# Update standard hearts (these are always present)
	var num_extra_hearts = hp_manager.max_extra_hp / hp_manager.HP_PER_HEART
	var joy_offset = 1 if hp_manager.max_joy_hp > 0 else 0
	for i in range(3):
		var heart_index = num_extra_hearts + joy_offset + i
		_update_heart(hearts[i], heart_index, hp_manager, HeartType.STANDARD)

func _on_extra_hearts_changed(extra_hp: int, max_extra_hp: int):
	var player = get_tree().get_first_node_in_group("player")
	var hp_manager = player.get_node("HpManager")
	
	var num_extra_hearts = max_extra_hp / hp_manager.HP_PER_HEART
	var current_extra_hearts = extra_hearts.size()
	
	# Add extra hearts if needed
	while current_extra_hearts < num_extra_hearts:
		_add_extra_heart_visual()
		current_extra_hearts += 1
	
	# Remove extra hearts if needed (remove from the right)
	while current_extra_hearts > num_extra_hearts:
		_remove_extra_heart_visual()
		current_extra_hearts -= 1
	
	# Update all extra heart visuals
	for i in range(extra_hearts.size()):
		_update_heart(extra_hearts[i], i, hp_manager, HeartType.EXTRA)

func _on_joy_heart_changed(joy_hp: int, max_joy_hp: int):
	var player = get_tree().get_first_node_in_group("player")
	var hp_manager = player.get_node("HpManager")
	
	# Add joy heart if it doesn't exist and max_joy_hp > 0
	if max_joy_hp > 0 and joy_heart == null:
		_add_joy_heart_visual()
	
	# Remove joy heart if it exists and max_joy_hp == 0
	if max_joy_hp == 0 and joy_heart != null:
		_remove_joy_heart_visual()
	
	# Update joy heart visual if it exists
	if joy_heart != null:
		var num_extra_hearts = hp_manager.max_extra_hp / hp_manager.HP_PER_HEART
		var joy_heart_index = num_extra_hearts
		_update_heart(joy_heart, joy_heart_index, hp_manager, HeartType.JOY)

func _add_joy_heart_visual():
	"""Create the joy heart visual after extra hearts"""
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(36, 32)
	
	# Duplicate heart sprite
	var new_heart = hearts[0].duplicate()
	
	# Ensure the sprite_frames resource is properly set
	if hearts[0].sprite_frames:
		new_heart.sprite_frames = hearts[0].sprite_frames
	
	wrapper.add_child(new_heart)
	
	# Add to the end (after extra hearts)
	add_child(wrapper)
	
	# Store references
	joy_heart_wrapper = wrapper
	joy_heart = new_heart
	
	print("Added joy heart at end")
	
	# Immediately update the heart's animation
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("HpManager"):
		var hp_manager = player.get_node("HpManager")
		var joy_heart_index = hp_manager.max_extra_hp / hp_manager.HP_PER_HEART
		_update_heart(joy_heart, joy_heart_index, hp_manager, HeartType.JOY)
		
		# Sync animation frame with the first heart for consistency
		if hearts[0].is_playing():
			new_heart.frame = hearts[0].frame
			new_heart.set_frame_and_progress(hearts[0].frame, hearts[0].frame_progress)
func _remove_joy_heart_visual():
	"""Remove the joy heart visual"""
	if joy_heart_wrapper != null:
		joy_heart_wrapper.queue_free()
		joy_heart_wrapper = null
		joy_heart = null
		print("Removed joy heart")

func _add_extra_heart_visual():
	"""Create a new extra heart visual at the end (rightmost)"""
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(36, 32)
	
	# Duplicate heart sprite
	var new_heart = hearts[0].duplicate()
	
	# Ensure the sprite_frames resource is properly set
	if hearts[0].sprite_frames:
		new_heart.sprite_frames = hearts[0].sprite_frames
	
	wrapper.add_child(new_heart)
	
	# Add to the end (rightmost) of HBoxContainer
	add_child(wrapper)
	
	# Store references
	extra_heart_wrappers.append(wrapper)
	extra_hearts.append(new_heart)
	
	print("Added extra heart at end")
	
	# Immediately update the heart's animation based on current HP
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("HpManager"):
		var hp_manager = player.get_node("HpManager")
		var heart_index = extra_hearts.size() - 1
		_update_heart(new_heart, heart_index, hp_manager, HeartType.EXTRA)
		
		# Sync animation frame with the first heart for consistency
		if hearts[0].is_playing():
			new_heart.frame = hearts[0].frame
			new_heart.set_frame_and_progress(hearts[0].frame, hearts[0].frame_progress)




func _remove_extra_heart_visual():
	"""Remove the rightmost extra heart visual"""
	if extra_hearts.size() > 0:
		var wrapper = extra_heart_wrappers.pop_back()
		extra_hearts.pop_back()
		wrapper.queue_free()

func _update_heart(heart: AnimatedSprite2D, heart_index: int, hp_manager: HPManager, heart_type: HeartType):
	"""Update a heart's visual based on its HP and type"""
	
	# Check if broken (only standard hearts can be broken)
	if heart_type == HeartType.STANDARD and hp_manager.is_heart_broken(heart_index):
		heart.play("broken")
		return
	
	# Get the animation prefix based on heart type
	var prefix = ""
	match heart_type:
		HeartType.STANDARD:
			prefix = "idle_"
		HeartType.EXTRA:
			prefix = "extra_"
		HeartType.HEALING:
			prefix = "healing_"
		HeartType.JOY:
			prefix = "joy_"
		HeartType.BROKEN:
			heart.play("broken")
			return
	
	var hp_in_heart = hp_manager.get_hp_in_heart(heart_index)
	
	# Play appropriate animation based on HP
	var anim_name = ""
	match hp_in_heart:
		3:
			anim_name = prefix + "full"
		2:
			anim_name = prefix + "2hp"
		1:
			anim_name = prefix + "1hp"
		0:
			anim_name = prefix + "empty"
	
	# Check if animation exists before playing
	if heart.sprite_frames and heart.sprite_frames.has_animation(anim_name):
		print("Playing animation: ", anim_name, " on heart type: ", HeartType.keys()[heart_type])
		heart.play(anim_name)
	else:
		push_warning("Animation not found: " + anim_name)
		print("Available animations: ", heart.sprite_frames.get_animation_names() if heart.sprite_frames else "No sprite_frames")
		# Fallback to idle animations if specific type not found
		var fallback = "idle_" + anim_name.split("_")[-1]
		if heart.sprite_frames and heart.sprite_frames.has_animation(fallback):
			heart.play(fallback)

func _on_heart_broken(heart_index: int):
	"""Handle heart broken event"""
	var player = get_tree().get_first_node_in_group("player")
	var hp_manager = player.get_node("HpManager")
	_on_health_changed(hp_manager.current_hp, hp_manager.get_max_hp())
