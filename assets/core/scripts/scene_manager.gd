extends Node #too mnay fuckin variables Jesus...

@export var live: Node2D
@export var gui : Control

enum  World {REALITY, DREAM}
enum ChangeOptions {DELETE, HIDE, PAUSE}

var current_world: World = World.REALITY
var current_reality_scene
var current_dream_scene
var current_gui_node: Node = null  # Store the actual node instance, not a file path
var current_player: Node = null
var reality_player_scene: Node = null  # Cache the reality player
var dream_player_scene: Node = null    # Cache the dream player

var live_scene # should store the name of the currently active scene, which is basically the most recently loaded scene

const DREAM_UI_SCENE := "res://assets/dream/scenes/ui/dream_hud.tscn"
const REALITY_UI_SCENE := "res://assets/reality/scenes/ui/reality_hud.tscn"
const REALITY_PLAYER_PATH := "res://assets/reality/scenes/player/reality_player.tscn"
const DREAM_PLAYER_PATH := "res://assets/dream/scenes/player/dream_player.tscn"

# Folder paths for auto-discovery
const REALITY_ROOMS_PATH := "res://assets/reality/scenes/rooms/"
const DREAM_REGIONS_PATH := "res://assets/dream/scenes/regions/"

# Auto-populated at runtime
var reality_rooms := {}
var dream_regions := {}


# Reality tracking
var current_reality_room: String = "demis_bedroom"  # Which reality room the player is 
# Dream tracking
var current_dream_region: String = "castle_in_the_sky"  # Which region

var scene_cache: Dictionary = {} # Store loaded scenes by path?
var hidden_gui_nodes: Dictionary = {}  # Track hidden scenes by their file path
var hidden_live_scenes: Dictionary = {}  # Track hidden live scenes by their scene path

func _ready() -> void:
	_scan_reality_rooms()
	_scan_dream_regions()
	# Don't auto-boot into reality - let main menu handle first scene load

func change_gui_scene(new_scene_path: String, option: ChangeOptions) -> void:
	print("[DEBUG] Trying to load: ", new_scene_path)
	print("[DEBUG] Current gui_node: ", current_gui_node)
	
	# Check if the scene we want is already hidden - if so, unhide it
	if hidden_gui_nodes.has(new_scene_path):
		print("[DEBUG] Found hidden instance, restoring it")
		# Hide the current visible one if needed
		if current_gui_node != null:
			if option == ChangeOptions.DELETE:
				current_gui_node.queue_free()
			elif option == ChangeOptions.HIDE:
				current_gui_node.visible = false
				if current_gui_node.scene_file_path != "":
					hidden_gui_nodes[current_gui_node.scene_file_path] = current_gui_node
			else:
				get_tree().root.remove_child(current_gui_node)
		
		# Restore the hidden one
		current_gui_node = hidden_gui_nodes[new_scene_path]
		current_gui_node.visible = true
		hidden_gui_nodes.erase(new_scene_path)
		return
	
	# If we're trying to load a scene that's already the current visible one, just ensure it's visible
	if current_gui_node != null and current_gui_node.scene_file_path == new_scene_path:
		print("[DEBUG] Same scene detected, just showing it")
		if not current_gui_node.visible:
			current_gui_node.visible = true
		return
	
	print("[DEBUG] Different scene or no current scene, proceeding...")
	
	if current_gui_node != null:
		if option == ChangeOptions.DELETE:
			current_gui_node.queue_free() #removes the node entirely from the scene tree, not running in the background or whatever, no dat beong stored for it anymore
		elif option == ChangeOptions.HIDE:
			print("[DEBUG] Hiding current scene")
			current_gui_node.visible = false #keeps in memory and running, probably fine for like pause menus n shit
			# Store it in the hidden dictionary
			if current_gui_node.scene_file_path != "":
				hidden_gui_nodes[current_gui_node.scene_file_path] = current_gui_node
		else:
			get_tree().root.remove_child(current_gui_node) # Keeps in memory does not run (pauses it lol ignore passed this point), so like moving from room to room in a house are without completely needing to load it in each time?
	
	# Load and add the new scene
	var new_scene: PackedScene = load(new_scene_path)
	if new_scene:
		current_gui_node = new_scene.instantiate()
		print("[DEBUG] New scene instantiated: ", current_gui_node)
		get_tree().root.add_child(current_gui_node)
	else:
		push_error("[SceneManager] Failed to load GUI scene: " + new_scene_path)

func change_live_scene(world: World, scene_name: String, option: ChangeOptions) -> void:
	var scene_path = ""
	# Get the scene path based on world type
	if world == World.REALITY:
		if not reality_rooms.has(scene_name):
			push_error("[SceneManager] Reality room not found: " + scene_name)
			return
		scene_path = reality_rooms[scene_name]
	else: # World.DREAM
		if not dream_regions.has(scene_name):
			push_error("[SceneManager] Dream region not found: " + scene_name)
			return
		scene_path = dream_regions[scene_name]
	
	# Check if the scene we want is already loaded and hidden
	if hidden_live_scenes.has(scene_path):
		print("[SceneManager] Restoring hidden scene: ", scene_name)
		
		# Handle current live scene first
		if live_scene != null:
			if option == ChangeOptions.DELETE:
				live_scene.queue_free()
			elif option == ChangeOptions.HIDE:
				live_scene.visible = false
				if live_scene.scene_file_path != "":
					hidden_live_scenes[live_scene.scene_file_path] = live_scene
			else: # PAUSE
				get_tree().root.remove_child(live_scene)
				if live_scene.scene_file_path != "":
					hidden_live_scenes[live_scene.scene_file_path] = live_scene
		
		# Restore the hidden scene
		live_scene = hidden_live_scenes[scene_path]
		hidden_live_scenes.erase(scene_path)
		
		if not live_scene.is_inside_tree():
			get_tree().root.add_child(live_scene)
		
		live_scene.visible = true
		# Switch player after restoring scene
		switch_player(world)
		return
	
	# Handle current live scene
	if live_scene != null:
		if option == ChangeOptions.DELETE:
			live_scene.queue_free()
		elif option == ChangeOptions.HIDE:
			live_scene.visible = false
			if live_scene.scene_file_path != "":
				hidden_live_scenes[live_scene.scene_file_path] = live_scene
		else: # PAUSE
			get_tree().root.remove_child(live_scene)
			if live_scene.scene_file_path != "":
				hidden_live_scenes[live_scene.scene_file_path] = live_scene
	
	# Scene not loaded yet, call the appropriate load function
	if world == World.REALITY:
		load_reality_room(scene_name)
	else:
		load_dream_region(scene_name)
	
	# Switch player after loading new scene
	switch_player(world)

func switch_player(world: World) -> void:
	current_world = world
	# Remove current player from tree (but keep in memory)
	if current_player != null:
		get_tree().root.remove_child(current_player)
	
	# Load or restore the appropriate player
	if world == World.REALITY:
		if reality_player_scene == null:
			# First time loading reality player
			var player_scene = load(REALITY_PLAYER_PATH)
			reality_player_scene = player_scene.instantiate()
		current_player = reality_player_scene
	else: # World.DREAM
		if dream_player_scene == null:
			# First time loading dream player
			var player_scene = load(DREAM_PLAYER_PATH)
			dream_player_scene = player_scene.instantiate()
		current_player = dream_player_scene
	
	# Add the appropriate player to the tree
	get_tree().root.add_child(current_player)

## ROOM AND REGION LOADING FUNCS: uhnm these are weird but im thinking ill have separate funcs for changing scenes and those or that function will be responsible for what happens to the scene that it was on previously yk?
func load_reality_room(room_name: String) -> void: # might need to add something for the spawn position here but otherwise this works great yay
	print("[SceneManager] Loading Reality room: ", room_name)
	
	var room_scene = load(reality_rooms[room_name])
	current_reality_scene = room_scene.instantiate()
	get_tree().root.add_child(current_reality_scene)
	live_scene = current_reality_scene

func load_dream_region(region_name: String) -> void:
	print("[SceneManager] Loading Dream region: ", region_name)
	
	var region_scene = load(dream_regions[region_name])
	current_dream_scene = region_scene.instantiate()
	get_tree().root.add_child(current_dream_scene)
	live_scene = current_dream_scene

##Idk gang but dont touch js yet

func _scan_reality_rooms() -> void:
	_scan_folder_recursive(REALITY_ROOMS_PATH, reality_rooms)
	print("[SceneManager] Found Reality rooms: ", reality_rooms.keys())

func _scan_dream_regions() -> void:
	_scan_folder_recursive(DREAM_REGIONS_PATH, dream_regions)
	print("[SceneManager] Found Dream regions: ", dream_regions.keys())

func _scan_folder_recursive(path: String, dict: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_warning("[SceneManager] Could not open directory: " + path)
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
	
func is_awake() -> bool:
	return current_world == World.REALITY
