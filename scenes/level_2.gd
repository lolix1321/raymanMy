extends Node2D

# Przeciągnij plik sceny meteorytu do inspektora w to miejsce
@export var meteor_scene: PackedScene 

func _on_meteor_timer_timeout():
	var meteor = meteor_scene.instantiate()
	
	# Ustawienie losowej pozycji startowej nad ekranem
	# Zakładamy, że spawnujemy go gdzieś po lewej stronie u góry
	meteor.position = Vector2(randf_range(-200, 500), -50)
	
	$ParallaxBackground/Background.add_child(meteor)
