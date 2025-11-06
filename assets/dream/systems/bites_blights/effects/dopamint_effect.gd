# effects/dopamint_effect.gd
# Dopamint: +30 Energy over 30 seconds (+3 energy every 3 seconds)
extends BiteBlightEffect

var tick_timer: float = 0.0
var tick_interval: float = 3.0
var energy_per_tick: int = 3

func on_start():
	print("Dopamint: Slow energy restore active")

func update(delta: float):
	tick_timer += delta
	
	if tick_timer >= tick_interval:
		player.change_energy(energy_per_tick)
		tick_timer = 0.0
		print("+3 energy from Dopamint")
