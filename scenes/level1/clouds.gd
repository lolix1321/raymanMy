extends ParallaxLayer

@export var CLOUDS_SPEED: float = -1.0
var current_offset: float = 0.0

func _process(delta: float) -> void:
	# Liczymy pozycję na liczbach ułamkowych (float)
	current_offset += CLOUDS_SPEED * delta
	# Przypisujemy do motion_offset
	motion_offset.x = current_offset
