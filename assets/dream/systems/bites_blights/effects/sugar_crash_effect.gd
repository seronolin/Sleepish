# effects/sugar_crash_effect.gd
# Sugar Crash: +18 Energy now, -21 Energy in 90 seconds
extends BiteBlightEffect

var crash_timer: float = 90.0
var has_crashed: bool = false

func on_start():
	print("Sugar rush active! Crash coming in 90 seconds...")

func update(delta: float):
	if has_crashed:
		return
	
	crash_timer -= delta
	
	if crash_timer <= 0:
		# CRASH!
		player.change_energy(-21)
		has_crashed = true
		print("Sugar crash! -21 energy")

func on_end(p_player: Node):
	# Make sure crash happens even if effect is removed early
	if not has_crashed:
		p_player.change_energy(-21)
