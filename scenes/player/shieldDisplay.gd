extends TextureProgressBar

var current_cooldown = 0.0
var is_active = false

func _process(delta):
	if is_active:
		current_cooldown -= delta
		value = current_cooldown
		
		if current_cooldown <= 0:
			is_active = false
			print("UI: Odliczanie zakończone")

# TA FUNKCJA MUSI BYĆ POŁĄCZONA SYGNAŁEM
func start_cooldown(time: float):
	print("UI: Sygnał odebrany! Czas: ", time)
	self.max_value = time
	self.value = time
	self.current_cooldown = time
	self.is_active = true
