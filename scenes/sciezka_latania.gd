extends PathFollow2D

@export var speed = 0.1 # Jak szybko lata

func _process(delta):
	progress_ratio += delta * speed
