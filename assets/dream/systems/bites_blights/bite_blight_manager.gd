# bite_blight_manager.gd
extends Node

# Track active effects on player
var active_effects: Array[ActiveEffect] = []

func _process(delta):
	# Update all active effects
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		if not effect.update(delta):
			# Effect expired
			remove_effect(effect)

func apply_powerup(player, data: BiteBlightData):
	print("Applied: ", data.powerup_name)
	
	# Instant effects (always apply these first)
	apply_instant_effects(player, data)
	
	# Create active effect tracker if it has duration
	if data.duration != 0:
		var effect = ActiveEffect.new(data.powerup_name, data)
		
		# Check for custom effect script
		if data.special_effect != "":
			var custom_effect = load_custom_effect(data.special_effect)
			if custom_effect:
				effect.custom_effect = custom_effect.new(player, data)
				effect.custom_effect.on_start()
		
		# Apply stat modifiers
		player.atk_multiplier *= data.atk_multiplier
		player.def_multiplier *= data.def_multiplier
		if "speed_multiplier" in player:
			player.speed_multiplier *= data.speed_multiplier
		
		# Apply simple special effects
		apply_simple_special_effects(player, data, effect)
		
		active_effects.append(effect)
	
	# Mode and mood changes
	if data.forces_mode != "None":
		force_player_mode(player, data.forces_mode)
	if data.locks_mode != "None":
		lock_player_mode(player, data.locks_mode)
	if data.forces_mood != "":
		if data.forces_mood == "User Choice":
			player.open_mood_choice_ui()
		else:
			player.force_mood(data.forces_mood)
	
	# Jump count modification
	if data.jump_count_change != 0:
		player.change_jump_count(data.jump_count_change)
	
	# Revive effect
	if data.grants_revive:
		player.add_revive_effect()
	
	# Shield effect
	if data.shields_granted > 0:
		player.add_shield_effect(data.shields_granted)
	
	# Summons
	if data.summons != "":
		spawn_summon(player, data.summons)

func apply_instant_effects(player, data: BiteBlightData):
	# Energy
	if data.energy_effect != 0:
		if data.energy_effect == 999999:  # Full restore marker
			player.energy = player.max_energy
		else:
			player.change_energy(data.energy_effect)
	
	# HP
	if data.hp_change != 0:
		if data.hp_change > 0:
			player.hp_manager.heal(data.hp_change)
		else:
			player.hp_manager.take_damage(abs(data.hp_change))
	
	# Extra Hearts (permanent until used)
	if data.extra_hearts > 0:
		player.hp_manager.add_extra_heart(data.extra_hearts)
	
	# Special instant effects
	if data.special_effect == "reset_stats":
		reset_all_stats(player)
	elif data.special_effect == "remove_mode_locks":
		player.unlock_mode()

func apply_simple_special_effects(player, data: BiteBlightData, effect: ActiveEffect):
	# These are simple toggles that don't need custom scripts
	if data.grants_double_dash:
		player.enable_double_dash()
		effect.custom_effect = DoubleDashEffect.new(player, data)
	
	if data.grants_extended_glide:
		player.extend_glide_time()
		effect.custom_effect = ExtendedGlideEffect.new(player, data)
	
	if data.grants_debuff_resistance:
		player.debuff_resistance = true
	
	if data.grants_status_immunity:
		player.status_immunity = true

func force_player_mode(player, mode: String):
	var current_energy = player.energy
	
	if mode == "Demidevil":
		# Force into Demidevil by setting threshold just below current energy
		player.energy_threshold = current_energy - 3
	elif mode == "Demise":
		# Force into Demise by setting threshold just above current energy
		player.energy_threshold = current_energy + 3

func lock_player_mode(player, mode: String):
	if mode == "Demidevil":
		player.lock_state_demidevil()
	elif mode == "Demise":
		player.lock_state_demise()

func load_custom_effect(effect_name: String) -> GDScript:
	var path = "res://systems/bites_blights/effects/%s_effect.gd" % effect_name
	if ResourceLoader.exists(path):
		return load(path)
	else:
		push_warning("Custom effect not found: %s" % path)
		return null

func remove_effect(effect: ActiveEffect):
	# Get player reference (assumes singleton or direct access)
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Revert stat modifiers
	player.atk_multiplier /= effect.applied_atk
	player.def_multiplier /= effect.applied_def
	if "speed_multiplier" in player:
		player.speed_multiplier /= effect.applied_speed
	
	# Cleanup custom effect
	effect.cleanup(player)
	
	# Remove simple special effects
	if effect.data.grants_double_dash:
		player.disable_double_dash()
	if effect.data.grants_extended_glide:
		player.reset_glide_time()
	if effect.data.grants_debuff_resistance:
		player.debuff_resistance = false
	if effect.data.grants_status_immunity:
		player.status_immunity = false
	
	active_effects.erase(effect)
	print(effect.effect_name, " effect ended")

func reset_all_stats(player):
	# Remove all stat modifier effects
	for effect in active_effects:
		player.atk_multiplier /= effect.applied_atk
		player.def_multiplier /= effect.applied_def
		if "speed_multiplier" in player:
			player.speed_multiplier /= effect.applied_speed
	
	# Reset to baseline
	player.atk_multiplier = 1.0
	player.def_multiplier = 1.0
	if "speed_multiplier" in player:
		player.speed_multiplier = 1.0

func spawn_summon(player, summon_name: String):
	# Load summon scene based on name
	var summon_path = "res://entities/summons/%s.tscn" % summon_name.to_snake_case()
	if ResourceLoader.exists(summon_path):
		var summon_scene = load(summon_path)
		var summon = summon_scene.instantiate()
		player.get_parent().add_child(summon)
		summon.global_position = player.global_position
		print("Summoned: ", summon_name)
	else:
		push_warning("Summon scene not found: %s" % summon_path)

func clear_all_effects():
	# Called when player rests
	var player = get_tree().get_first_node_in_group("player")
	for effect in active_effects:
		if effect.is_permanent:
			effect.cleanup(player)
	active_effects.clear()

func get_active_effects() -> Array[ActiveEffect]:
	return active_effects

# Built-in simple effect classes
class DoubleDashEffect extends BiteBlightEffect:
	func on_end(p_player: Node):
		p_player.disable_double_dash()

class ExtendedGlideEffect extends BiteBlightEffect:
	func on_end(p_player: Node):
		p_player.reset_glide_time()
