extends Node

# Current world state
enum WorldType { REALITY, DREAM }
var current_world: WorldType = WorldType.REALITY

# Scene references
var dream_scenes = {}  # Will store dream area scenes
var reality_scenes = {} # Will store reality location scenes
var current_scene_path: String = ""

# Persistent data
var sleep_location: String = ""  # Where the player fell asleep
var game_time: float = 0.0  # Real time tracker

signal world_changed(new_world: WorldType)
signal scene_changed(new_scene_path: String)

func _ready():
	pass

# Switch between Dream and Reality worlds
func switch_world(target_world: WorldType, target_scene: String = ""):
	if target_world != current_world:
		current_world = target_world
		world_changed.emit(current_world)
	
	if target_scene != "":
		load_scene(target_scene)

# Load a specific scene within current world
func load_scene(scene_path: String):
	if scene_path == current_scene_path:
		return
	
	current_scene_path = scene_path
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit(scene_path)

# Sleep system
func go_to_sleep(location_id: String):
	sleep_location = location_id
	# TODO: Add fade animation here
	switch_world(WorldType.DREAM, "res://scenes/dream/starting_area.tscn")

func wake_up():
	# TODO: Add wake up animation here  
	var return_scene = "res://scenes/reality/" + sleep_location + ".tscn"
	switch_world(WorldType.REALITY, return_scene)

func _process(delta):
	game_time += delta
