extends ProgressBar

func set_bar_values(current, max_energy, min_energy, energy_threshold):
	max_value = max_energy
	min_value = min_energy
	value = current
