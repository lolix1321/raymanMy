extends ParallaxLayer
@export var float_distance = 10.0 # Jak mocno się buja (piksele)
@export var float_time = 8.0      # Jak długo trwa jeden ruch (im więcej tym wolniej/ciężej)

func _ready():
	start_floating()

func start_floating():
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Ruch w górę
	tween.tween_property(self, "position:y", position.y - float_distance, float_time)
	# Ruch w dół (powrót)
	tween.tween_property(self, "position:y", position.y + float_distance, float_time)
