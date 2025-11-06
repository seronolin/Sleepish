# game_manager.gd
# Autoload singleton that orchestrates world swapping and room loading
extends Node

# Folder paths for auto-discovery
const REALITY_ROOMS_PATH := "res://assets/reality/scenes/rooms/"
const DREAM_REGIONS_PATH := "res://assets/dream/scenes/regions/"

# Player prefabs
const REALITY_PLAYER_SCENE := "res://assets/reality/scenes/player/reality_player.tscn"
const DREAM_PLAYER_SCENE := "res://assets/dream/scenes/player/dream_player.tscn"

# UI prefabs
const DREAM_UI_SCENE := "res://assets/dream/scenes/ui/dream_hud.tscn"
const REALITY_UI_SCENE := "res://assets/dream/scenes/ui/dream_hud.tscn"

# Current state
var current_world: Node = null
var current_player: CharacterBody2D = null
var current_ui: Node = null  # Track current UI (can be CanvasLayer or Control)
var in_dream: bool = false  # Track which world we're in

# Reality tracking
var current_reality_room: String = "demis_bedroom"  # Which room/scene player is in
var sleep_location: Vector2 = Vector2(320, 180)     # Where they fell asleep (can be overridden)

# Dream tracking
var current_dream_region: String = "castle_in_the_sky"  # Which region
var dream_spawn_point: Vector2 = Vector2(100, 100)      # Last checkpoint or override
var last_checkpoint_id: String = ""                     # For checkpoint system later

# Auto-populated at runtime
var reality_rooms := {}
var dream_regions := {}

func _ready() -> void:
	print("[GameManager] Ready")
	_scan_reality_rooms()
	_scan_dream_regions()
	# Don't auto-boot into reality - let main menu handle first scene load

func _scan_reality_rooms() -> void:
	_scan_folder_recursive(REALITY_ROOMS_PATH, reality_rooms)
	print("[GameManager] Found Reality rooms: ", reality_rooms.keys())

func _scan_dream_regions() -> void:
	_scan_folder_recursive(DREAM_REGIONS_PATH, dream_regions)
	print("[GameManager] Found Dream regions: ", dream_regions.keys())

func _scan_folder_recursive(path: String, dict: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_warning("[GameManager] Could not open directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + file_name
		
		if dir.current_is_dir():
			# Recursively scan subdirectories
			_scan_folder_recursive(full_path + "/", dict)
		elif file_name.ends_with(".tscn"):
			# Extract scene name without extension
			var scene_name = file_name.replace(".tscn", "")
			dict[scene_name] = full_path
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

## ROOM/REGION LOADING ##

func load_reality_room(room_name: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	print("[GameManager] Loading Reality room: ", room_name)
	
	# Check if room exists
	if not reality_rooms.has(room_name):
		push_error("[GameManager] Reality room not found: " + room_name)
		print("[GameManager] Available rooms: ", reality_rooms.keys())
		return
	
	# Unload current UI
	if current_ui:
		current_ui.queue_free()
		await current_ui.tree_exited
		current_ui = null
	
	# Unload current world
	if current_world:
		current_world.queue_free()
		await current_world.tree_exited
		current_world = null
	
	# Unload current player
	if current_player:
		current_player.queue_free()
		await current_player.tree_exited
		current_player = null
	
	# Load room scene
	var room_scene = load(reality_rooms[room_name])
	current_world = room_scene.instantiate()
	get_tree().root.add_child(current_world)
	
	# Load and spawn player
	var player_scene = load(REALITY_PLAYER_SCENE)
	current_player = player_scene.instantiate()
	current_world.add_child(current_player)
	current_player.global_position = spawn_position
	
	# Load UI if it exists
	if ResourceLoader.exists(REALITY_UI_SCENE):
		var ui_scene = load(REALITY_UI_SCENE)
		current_ui = ui_scene.instantiate()
		get_tree().root.add_child(current_ui)
		print("[GameManager] Reality UI loaded")
	
	# Update tracking
	current_reality_room = room_name
	in_dream = false  # We're in Reality
	
	print("[GameManager] Reality room loaded: ", room_name, " at ", spawn_position)

func load_dream_region(region_name: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	print("[GameManager] Loading Dream region: ", region_name)
	
	# Check if region exists
	if not dream_regions.has(region_name):
		push_error("[GameManager] Dream region not found: " + region_name)
		print("[GameManager] Available regions: ", dream_regions.keys())
		return
	
	print("[GameManager] Unloading current UI...")
	# Unload current UI
	if current_ui:
		current_ui.queue_free()
		await current_ui.tree_exited
		current_ui = null
	
	print("[GameManager] Unloading current world...")
	# Unload current world
	if current_world:
		current_world.queue_free()
		await current_world.tree_exited
		current_world = null
	
	print("[GameManager] Unloading current player...")
	# Unload current player
	if current_player:
		current_player.queue_free()
		await current_player.tree_exited
		current_player = null
	
	print("[GameManager] Loading region scene...")
	# Load region scene
	var region_scene = load(dream_regions[region_name])
	current_world = region_scene.instantiate()
	get_tree().root.add_child(current_world)
	print("[GameManager] Region scene added to tree")
	
	print("[GameManager] Loading player...")
	# Load and spawn player
	var player_scene = load(DREAM_PLAYER_SCENE)
	current_player = player_scene.instantiate()
	current_world.add_child(current_player)
	current_player.global_position = spawn_position
	print("[GameManager] Player spawned at: ", spawn_position)
	
	print("[GameManager] Loading Dream UI...")
	# Load Dream UI
	var ui_scene = load(DREAM_UI_SCENE)
	current_ui = ui_scene.instantiate()
	get_tree().root.add_child(current_ui)
	print("[GameManager] Dream UI loaded")
	
	# Update tracking
	current_dream_region = region_name
	in_dream = true  # We're in Dream
	
	print("[GameManager] Dream region loaded: ", region_name, " at ", spawn_position)

## SLEEP/WAKE TRANSITIONS ##

func initiate_sleep(is_voluntary: bool = true) -> void:
	print("[GameManager] Initiating sleep (voluntary: %s)..." % is_voluntary)
	GameClock.stop_clock()
	
	# Save where player fell asleep
	if current_player:
		sleep_location = current_player.global_position
		print("[GameManager] Fell asleep at: ", sleep_location, " in ", current_reality_room)
	
	# Load dream at spawn point (checkpoint or override)
	load_dream_region(current_dream_region, dream_spawn_point)
	GameClock.start_clock()

func initiate_wake() -> void:
	print("[GameManager] Initiating wake...")
	GameClock.stop_clock()
	
	# Save dream position for next time
	if current_player:
		dream_spawn_point = current_player.global_position
		print("[GameManager] Saved dream position: ", dream_spawn_point)
	
	# Wake up where you fell asleep
	load_reality_room(current_reality_room, sleep_location)
	GameClock.start_clock()

## HELPER METHODS ##

func is_in_reality() -> bool:
	return not in_dream

func is_in_dream() -> bool:
	return in_dream

func override_sleep_location(new_location: Vector2) -> void:
	sleep_location = new_location
	print("[GameManager] Sleep location overridden to: ", new_location)

func override_dream_spawn(new_spawn: Vector2) -> void:
	dream_spawn_point = new_spawn
	print("[GameManager] Dream spawn overridden to: ", new_spawn)

func set_checkpoint(checkpoint_id: String, position: Vector2) -> void:
	last_checkpoint_id = checkpoint_id
	dream_spawn_point = position
	print("[GameManager] Checkpoint set: ", checkpoint_id, " at ", position)
