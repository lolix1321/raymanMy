extends Node


var target_scene_path: String

func load_level(path: String):
	target_scene_path = path
	
	get_tree().change_scene_to_file("res://LOADINGSCREEN/loading_screen.tscn")
