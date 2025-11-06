## Manages all player skills
## Handles skill switching based on state/mood and E input
extends Node

## References
@onready var player: CharacterBody2D = get_parent()
var mood_manager: Node
var hp_manager: Node

## Current active skill
var current_skill: Skill = null

## Skill storage - organized by [mode][mood]
## "demidevil" or "demise" -> "anger", "sadness", "joy", "neutral"
var skills: Dictionary = {}

## Signals
signal skill_changed(new_skill: Skill)
signal skill_executed(skill_name: String)

func _ready() -> void:
	## Get references to other player systems
	mood_manager = player.get_node_or_null("MoodManager")
	hp_manager = player.get_node_or_null("HpManager")
	
	if not mood_manager:
		push_error("SkillManager: MoodManager not found!")
	if not hp_manager:
		push_error("SkillManager: HpManager not found!")
	
	## Initialize skill dictionary structure
	skills = {
		"demidevil": {
			"anger": null,
			"sadness": null,
			"joy": null,
			"neutral": null
		},
		"demise": {
			"anger": null,
			"sadness": null,
			"joy": null,
			"neutral": null
		}
	}
	
	## Setup skills (we'll add them manually in the next steps)
	call_deferred("_setup_skills")

func _setup_skills() -> void:
	## Shield skill (Demise + Sadness)
	## The skill script should already be attached to a child node
	var shield_skill = get_node_or_null("ShieldSkill")
	if shield_skill:
		register_skill("demise", "sadness", shield_skill)
	else:
		push_warning("SkillManager: Shield skill node not found!")

## Call this to add a skill to the manager
func register_skill(mode: String, mood: String, skill: Skill) -> void:
	if not skills.has(mode):
		push_error("Invalid mode: " + mode)
		return
	if not skills[mode].has(mood):
		push_error("Invalid mood: " + mood)
		return
	
	## Add skill as child node
	add_child(skill)
	
	## Set skill references
	skill.player = player
	skill.hp_manager = hp_manager
	skill.mood_manager = mood_manager
	
	## Store in dictionary
	skills[mode][mood] = skill
	
	print("Registered skill: ", skill.skill_name, " (", mode, " + ", mood, ")")

func _process(delta: float) -> void:
	## Update current skill based on state/mood
	_update_current_skill()

func _unhandled_input(event: InputEvent) -> void:
	## E key to execute skill
	if event.is_action_pressed("skill"):
		execute_current_skill()

## Execute the current active skill
func execute_current_skill() -> void:
	if not current_skill:
		print("No skill equipped")
		return
	
	if current_skill.try_execute():
		skill_executed.emit(current_skill.skill_name)
		print("✓ Executed: ", current_skill.skill_name)
	else:
		print("✗ Can't use ", current_skill.skill_name, " (cooldown or already active)")

## Update which skill is currently active based on mode + mood
func _update_current_skill() -> void:
	if not mood_manager:
		return
	
	## Get current mode and mood from your MoodManager
	var mode = _get_current_mode()
	var mood = _get_current_mood()
	
	## Look up the skill for this mode+mood combo
	var new_skill = skills.get(mode, {}).get(mood, null)
	
	## If skill changed, switch to it
	if new_skill != current_skill:
		## End previous skill if it was active
		if current_skill and current_skill.is_active:
			current_skill.end_skill()
		
		current_skill = new_skill
		skill_changed.emit(current_skill)
		
		if current_skill:
			print("→ Skill equipped: ", current_skill.skill_name)
		else:
			print("→ No skill for ", mode, " + ", mood)

## Helper: Get current mode from player controller
func _get_current_mode() -> String:
	if not player:
		return "demise"
	
	## Read from PlayerController's current_mode_type enum
	match player.current_mode_type:
		player.Mode.DEMIDEVIL:
			return "demidevil"
		player.Mode.DEMISE:
			return "demise"
		_:
			push_warning("SkillManager: Unknown mode type")
			return "demise"

## Helper: Get current mood from mood manager
func _get_current_mood() -> String:
	if not mood_manager or not mood_manager.current_mood:
		return "neutral"
	
	## Read the node name and convert to lowercase
	var mood_name = mood_manager.current_mood.name.to_lower()
	return mood_name

## Get current skill (for UI)
func get_current_skill() -> Skill:
	return current_skill
