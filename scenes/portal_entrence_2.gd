extends Area2D

var entered := false
var teleporting := false
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(_body):
	entered = true

func _on_body_exited(_body):
	entered = false



func _process(_delta):
	if entered and not teleporting:
		if Input.is_action_just_pressed("ui_accept"):
			teleporting = true
			player.start_portal_effect(true) 
			$EnterTimer.start()


		

func _on_enter_timer_timeout():
	Global.spawn_position = Vector2(295, 405) 
	get_tree().change_scene_to_file("res://scenes/portal_one_menu.tscn")
