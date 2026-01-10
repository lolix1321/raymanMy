extends GPUParticles2D



func _ready():
	emitting = true # Uruchamia wybuch krwi zaraz po stworzeniu
	# Czekamy aż animacja wygaśnie (czas trwania + czas życia cząsteczek)
	await get_tree().create_timer(lifetime + 1.0).timeout
	queue_free() # Usuwa obiekt z gry, żeby nie zamulać procesora


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
