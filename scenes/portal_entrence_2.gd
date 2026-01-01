extends Area2D

var entered := false
var teleporting := false
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(_body):
	entered = true

func _on_body_exited(_body):
	entered = false

# ... reszta kodu bez zmian ...

func _process(_delta):
	if entered and not teleporting:
		if Input.is_action_just_pressed("ui_accept"):
			teleporting = true
			# DODAJ ARGUMENT 'true' TUTAJ:
			player.start_portal_effect(true) 
			$EnterTimer.start()

# ... reszta kodu bez zmian ...

		

func _on_enter_timer_timeout():
	Global.spawn_position = Vector2(295, 405) # Twoja docelowa pozycja
	get_tree().change_scene_to_file("res://scenes/portal_one_menu.tscn")
