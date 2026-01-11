extends Camera2D

@export var decay := 0.8  
@export var max_offset := Vector2(100, 75)  
@export var max_roll := 0.1  

# Przechowujemy Twoje domyślne wartości
var base_offset := Vector2.ZERO
var trauma := 0.0  
var trauma_power := 2  

func _ready():
	# Zapamiętujemy początkowe ustawienie (Twoje 5.5, 5.5)
	base_offset = offset

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	elif offset != base_offset:
		# Kiedy wstrząs się kończy, upewniamy się, że wracamy do bazy
		offset = base_offset
		rotation = 0

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	
	# Dodajemy losowe przesunięcie do Twojego bazowego offsetu
	offset.x = base_offset.x + max_offset.x * amount * randf_range(-1, 1)
	offset.y = base_offset.y + max_offset.y * amount * randf_range(-1, 1)

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)
	
