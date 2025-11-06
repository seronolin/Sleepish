# glossary_manager.gd
extends Node

# Discovered items tracking
var discovered_powerups: Array[BiteBlightData] = []

# Save/Load
const SAVE_PATH = "user://glossary_save.dat"

func _ready():
	load_discoveries()

func register_discovered(data: BiteBlightData):
	# Check if already discovered
	for item in discovered_powerups:
		if item.powerup_name == data.powerup_name:
			return  # Already have it
	
	discovered_powerups.append(data)
	print("Discovered: ", data.powerup_name)
	
	# Auto-save discoveries
	save_discoveries()

func is_discovered(powerup_name: String) -> bool:
	for item in discovered_powerups:
		if item.powerup_name == powerup_name:
			return true
	return false

# Filtering functions
func get_all_bites() -> Array[BiteBlightData]:
	return discovered_powerups.filter(func(d): return d.type == "Bite")

func get_all_blights() -> Array[BiteBlightData]:
	return discovered_powerups.filter(func(d): return d.type == "Blight")

func get_by_rarity(rarity: String) -> Array[BiteBlightData]:
	return discovered_powerups.filter(func(d): return d.rarity == rarity)

func get_by_source(source: String) -> Array[BiteBlightData]:
	return discovered_powerups.filter(func(d): return d.source == source)

func get_by_name(name: String) -> BiteBlightData:
	for data in discovered_powerups:
		if data.powerup_name == name:
			return data
	return null

# Stats functions
func get_discovery_count() -> int:
	return discovered_powerups.size()

func get_total_possible_count() -> int:
	# Count all powerup resources in the data folder
	var count = 0
	var dir = DirAccess.open("res://data/bites_blights/")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				count += 1
			file_name = dir.get_next()
	
	return count

func get_completion_percentage() -> float:
	var total = get_total_possible_count()
	if total == 0:
		return 0.0
	return (float(discovered_powerups.size()) / float(total)) * 100.0

# Save/Load system
func save_discoveries():
	var save_data = {
		"discovered": []
	}
	
	# Store resource paths instead of full data
	for item in discovered_powerups:
		save_data.discovered.append(item.resource_path)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_discoveries():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data and save_data.has("discovered"):
			discovered_powerups.clear()
			for path in save_data.discovered:
				var data = load(path)
				if data:
					discovered_powerups.append(data)

func clear_all_discoveries():
	discovered_powerups.clear()
	save_discoveries()
	print("All discoveries cleared")
