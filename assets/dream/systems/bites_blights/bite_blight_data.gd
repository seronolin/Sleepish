# bite_blight_data.gd
extends Resource
class_name BiteBlightData

# Basic Info
@export var powerup_name: String = ""
@export_enum("Bite", "Blight", "???") var type: String = "Bite"
@export_enum("Common", "Gourmet", "Epicurean") var rarity: String = "Common"
@export_multiline var description: String = ""
@export_multiline var flavor_text: String = ""
@export var icon: Texture2D

# Acquisition
@export_enum("Crafted", "Purchased", "Found", "Reward", "Received", "Special") var acquisition: String = "Found"
@export_enum("Homemade", "Store-bought", "Agency-Provisioned") var source: String = "Store-bought"

# Basic Effects (applied instantly unless duration > 0)
@export var energy_effect: int = 0
@export var hp_change: int = 0
@export var extra_hearts: int = 0  # Adds temporary max HP hearts

# Stat Modifiers (use 1.0 for no change)
@export var atk_multiplier: float = 1.0
@export var def_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0

# Duration & Cooldown
@export var duration: float = 0.0  # 0 = instant, -1 = until rest, > 0 = timed
@export var cooldown: float = 0.0

# Mode & Mood
@export_enum("None", "Demidevil", "Demise") var forces_mode: String = "None"
@export_enum("None", "Demidevil", "Demise") var locks_mode: String = "None"
@export var forces_mood: String = ""  # "Sad", "Happy", "Angry", "User Choice"

# Jump System
@export var jump_count_change: int = 0  # 0 = no change, positive/negative to modify

# Special Effects
# If this is set, manager will look for a custom effect script
# Example: "sugar_crash" will load res://systems/bites_blights/effects/sugar_crash_effect.gd
@export var special_effect: String = ""

# For simple special effects that don't need custom scripts
@export var grants_double_dash: bool = false
@export var grants_extended_glide: bool = false
@export var grants_debuff_resistance: bool = false
@export var grants_status_immunity: bool = false
@export var grants_revive: bool = false
@export var shields_granted: int = 0  # Number of shields to grant

# Summons
@export var summons: String = ""  # "Worry Wisp", "Pixel Phantom", etc.

# Drawbacks (for UI/glossary display)
@export_multiline var drawback_description: String = ""
