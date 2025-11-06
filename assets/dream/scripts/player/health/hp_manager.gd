# hp_manager.gd
extends Node
class_name HPManager

signal health_changed(current, maximum)
signal damage_taken(amount: int)
signal heart_broken(heart_index)
signal extra_hearts_changed(extra_hp, max_extra_hp)
signal joy_heart_changed(joy_hp, max_joy_hp)
signal revive_added(revive_count)
signal revive_used(revive_count)
signal shield_added(shield_count)
signal shield_used(shield_count)
signal player_died()

const BASE_HEARTS: int = 3
const HP_PER_HEART: int = 3
const MIN_HEALTH: int = 0
const DEFAULT_MAX_HEALTH: int = 9  # 3 hearts × 3 HP

var current_hp: int = DEFAULT_MAX_HEALTH  # Standard hearts HP only
var extra_hp: int = 0  # Extra hearts HP (blue hearts - separate pool)
var max_extra_hp: int = 0  # Maximum extra heart HP
var joy_hp: int = 0  # Joy heart HP (yellow heart - separate pool)
var max_joy_hp: int = 0  # Maximum joy heart HP
var broken_hearts: int = 0
var queued_revives: int = 0
var queued_shields: int = 0

@onready var player: PlayerController = get_parent()

func _ready():
	# Emit initial health so UI updates
	health_changed.emit(current_hp, get_max_hp())
	extra_hearts_changed.emit(extra_hp, max_extra_hp)
	joy_heart_changed.emit(joy_hp, max_joy_hp)
	print(current_hp)

func get_max_hp() -> int:
	"""Returns maximum HP for STANDARD hearts only"""
	var working_hearts = BASE_HEARTS - broken_hearts
	return working_hearts * HP_PER_HEART

func get_total_max_hp() -> int:
	"""Returns maximum HP including extra hearts and joy heart"""
	return get_max_hp() + max_extra_hp + max_joy_hp

func get_total_current_hp() -> int:
	"""Returns current HP including extra hearts and joy heart"""
	return current_hp + extra_hp + joy_hp

func take_damage(amount: int):
	# Check if player has shields to block damage
	if has_shields():
		consume_shield()
		# Damage was blocked by shield!
		return
	
	# Apply player's hurting multiplier
	var actual_damage = int(amount * player.hurting_multiplier)
	
	# Damage priority: Extra HP -> Joy HP -> Standard HP
	# Drain extra hearts first
	if extra_hp > 0:
		var damage_to_extra = min(actual_damage, extra_hp)
		extra_hp -= damage_to_extra
		actual_damage -= damage_to_extra
		
		# Remove empty extra hearts one at a time
		while max_extra_hp > 0 and extra_hp < max_extra_hp - (HP_PER_HEART - 1):
			# If extra_hp can't fill the rightmost heart, remove it
			max_extra_hp -= HP_PER_HEART
		
		extra_hearts_changed.emit(extra_hp, max_extra_hp)
	
	# Then drain joy heart
	if actual_damage > 0 and joy_hp > 0:
		var damage_to_joy = min(actual_damage, joy_hp)
		joy_hp -= damage_to_joy
		actual_damage -= damage_to_joy
		joy_heart_changed.emit(joy_hp, max_joy_hp)
	
	# Finally drain standard HP
	if actual_damage > 0:
		current_hp -= actual_damage
		current_hp = clamp(current_hp, MIN_HEALTH, get_max_hp())
	
	# Check for death
	if current_hp <= 0:
		player_died.emit()
	else:
		health_changed.emit(current_hp, get_max_hp())

func heal(amount: int):
	# Apply player's healing multiplier
	var actual_heal = int(amount * player.healing_multiplier)
	
	# Heal standard hearts first
	var old_hp = current_hp
	current_hp += actual_heal
	current_hp = clamp(current_hp, MIN_HEALTH, get_max_hp())
	
	var healed_standard = current_hp - old_hp
	var overflow = actual_heal - healed_standard
	
	# Heal extra hearts if standard hearts are full AND there's overflow
	if current_hp == get_max_hp() and overflow > 0 and max_extra_hp > 0:
		var old_extra = extra_hp
		extra_hp += overflow
		extra_hp = clamp(extra_hp, 0, max_extra_hp)
		var healed_extra = extra_hp - old_extra
		overflow -= healed_extra
		extra_hearts_changed.emit(extra_hp, max_extra_hp)
	
	# Heal joy heart if both standard and extra hearts are full AND there's overflow
	if current_hp == get_max_hp() and extra_hp == max_extra_hp and overflow > 0 and max_joy_hp > 0:
		joy_hp += overflow
		joy_hp = clamp(joy_hp, 0, max_joy_hp)
		joy_heart_changed.emit(joy_hp, max_joy_hp)
	
	health_changed.emit(current_hp, get_max_hp())

func add_shields(count: int):
	queued_shields += count
	shield_added.emit(queued_shields)
	print("Shield(s) added! Total shields: ", queued_shields)
	update_shield_opacity()

func add_revive():
	queued_revives += 1
	revive_added.emit(queued_revives)
	if has_revives():
		$"../halobar".visible = true
	print("Revive added! Total revives: ", queued_revives)

func consume_revive():
	if has_revives():
		queued_revives -= 1
		# Revive with full health (all pools)
		current_hp = get_max_hp()
		extra_hp = max_extra_hp
		joy_hp = max_joy_hp
		revive_used.emit(queued_revives)
		health_changed.emit(current_hp, get_max_hp())
		extra_hearts_changed.emit(extra_hp, max_extra_hp)
		joy_heart_changed.emit(joy_hp, max_joy_hp)
		if has_revives() == false:
			$"../halobar".visible = false
		print("Revive consumed! Remaining: ", queued_revives)
		return true
	return false

func consume_shield():
	if has_shields():
		queued_shields -= 1
		shield_used.emit(queued_shields)
		update_shield_opacity()
		print("Shield consumed! Remaining: ", queued_shields)
		return true
	return false

func update_shield_opacity():
	var shield_sprite = $"../shield"
	if not shield_sprite:
		return
	
	if not has_shields():
		shield_sprite.visible = false
		return
	
	shield_sprite.visible = true
	
	# Set opacity based on shield count
	match queued_shields:
		1:
			shield_sprite.modulate.a = 0.45  # 45% opacity
		2:
			shield_sprite.modulate.a = 0.60  # 60% opacity
		_:  # 3 or higher
			shield_sprite.modulate.a = 0.75  # 75% opacity

func has_revives() -> bool:
	return queued_revives > 0

func has_shields() -> bool:
	return queued_shields > 0

func break_heart(heart_index: int):
	# Permanently break a standard heart
	if heart_index < BASE_HEARTS and broken_hearts < BASE_HEARTS:
		broken_hearts += 1
		current_hp = min(current_hp, get_max_hp())
		heart_broken.emit(heart_index)
		health_changed.emit(current_hp, get_max_hp())

func add_extra_heart(number: int):
	"""Add an extra heart from Bites & Blights or other sources"""
	max_extra_hp += HP_PER_HEART * number
	extra_hp += HP_PER_HEART * number # Fill the new heart
	extra_hearts_changed.emit(extra_hp, max_extra_hp)

func remove_extra_heart(amount: int = 1):
	"""Remove extra hearts (removes empty hearts first)"""
	var hearts_to_remove = min(amount, max_extra_hp / HP_PER_HEART)
	if hearts_to_remove > 0:
		max_extra_hp -= hearts_to_remove * HP_PER_HEART
		extra_hp = min(extra_hp, max_extra_hp)
		extra_hearts_changed.emit(extra_hp, max_extra_hp)

func add_joy_heart():
	"""Add the extra heart from Joy mood"""
	if max_joy_hp == 0:  # Only add if Joy hasn't already added one
		max_joy_hp = HP_PER_HEART
		joy_hp = HP_PER_HEART  # Fill the new heart
		joy_heart_changed.emit(joy_hp, max_joy_hp)
		print("Joy heart added!")

func remove_joy_heart():
	"""Remove the extra heart from Joy mood ending"""
	if max_joy_hp > 0:
		max_joy_hp = 0
		joy_hp = 0
		joy_heart_changed.emit(joy_hp, max_joy_hp)
		print("Joy heart removed!")

func get_hp_in_heart(heart_index: int) -> int:
	"""
	Get HP in a specific heart by visual index (left to right)
	Visual order: [Extra Hearts...] [Joy Heart] [Standard Hearts...]
	Drain order: Extra hearts drain first (left to right), then joy heart, then standard hearts (left to right)
	"""
	
	# Calculate how many extra hearts exist
	var num_extra_hearts = max_extra_hp / HP_PER_HEART
	
	# Check if this is an extra heart
	if heart_index < num_extra_hearts:
		# This is an extra heart
		var extra_heart_hp_start = heart_index * HP_PER_HEART
		var extra_heart_hp_end = extra_heart_hp_start + HP_PER_HEART
		
		if extra_hp <= extra_heart_hp_start:
			return 0  # This heart is empty
		elif extra_hp >= extra_heart_hp_end:
			return HP_PER_HEART  # This heart is full
		else:
			return extra_hp - extra_heart_hp_start  # Partial
	
	# Adjust index for extra hearts
	var adjusted_index = heart_index - num_extra_hearts
	
	# Check if this is the joy heart
	if max_joy_hp > 0 and adjusted_index == 0:
		return joy_hp  # Joy heart HP (0-3)
	
	# Adjust index if joy heart exists
	if max_joy_hp > 0:
		adjusted_index -= 1
	
	# This is a standard heart
	var standard_heart_index = adjusted_index
	
	# Check if broken
	if standard_heart_index < broken_hearts:
		return 0  # Broken hearts hold no HP
	
	# Adjust for broken hearts
	var working_standard_index = standard_heart_index - broken_hearts
	
	# Standard hearts drain left to right
	var standard_hp_start = working_standard_index * HP_PER_HEART
	var standard_hp_end = standard_hp_start + HP_PER_HEART
	
	if current_hp <= standard_hp_start:
		return 0  # This heart is empty
	elif current_hp >= standard_hp_end:
		return HP_PER_HEART  # This heart is full
	else:
		return current_hp - standard_hp_start  # Partial

func is_heart_broken(heart_index: int) -> bool:
	"""Check if a standard heart is broken (only applies to standard hearts)"""
	# Calculate how many extra hearts exist
	var num_extra_hearts = max_extra_hp / HP_PER_HEART
	
	# Adjust for extra hearts
	var adjusted_index = heart_index - num_extra_hearts
	
	# Adjust for joy heart if it exists
	if max_joy_hp > 0:
		adjusted_index -= 1
	
	if adjusted_index < 0:
		return false  # Extra or joy hearts can't be broken
	
	return adjusted_index < broken_hearts
