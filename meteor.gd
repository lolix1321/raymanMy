extends Area2D

@export var max_speed: float = 1400.0  # Prędkość dla największej gwiazdy
@export var min_speed: float = 400.0   # Prędkość dla najmniejszej gwiazdy
@export var direction: Vector2 = Vector2(1.5, 1.0)
@export var fade_speed: float = 1.5 

var current_speed: float = 0.0

func _ready():
	# 1. Losujemy skalę
	var s = randf_range(0.2, 0.5)
	scale = Vector2(s, s)
	
	# 2. Obliczamy prędkość na podstawie skali (Interpolacja liniowa)
	# remap mapuje skalę (0.2 - 0.9) na zakres prędkości (min_speed - max_speed)
	current_speed = remap(s, 0.2, 0.9, min_speed, max_speed)
	
	# 3. Opcjonalnie: mniejsze gwiazdy (te dalej) mogą znikać wolniej
	fade_speed = remap(s, 0.2, 0.9, 0.8, 2.5)
	
	

func _process(delta):
	# Ruch z obliczoną prędkością
	position += direction.normalized() * current_speed * delta
	
	# Efekt znikania
	modulate.a -= fade_speed * delta
	
	if modulate.a <= 0:
		queue_free()
