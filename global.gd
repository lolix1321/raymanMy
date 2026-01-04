extends Node

var spawn_position: Vector2 = Vector2.ZERO
var target_spawn_name: String = ""
var last_checkpoint_pos : Vector2 = Vector2.ZERO

var diamonds = 0
signal diamonds_updated(new_amount) # Sygnał informujący o zmianie

func add_diamond():
	diamonds += 1
	diamonds_updated.emit(diamonds) # Wysyłamy info do UI
