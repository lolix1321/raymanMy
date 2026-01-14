extends Area2D

var entered := false
var teleporting := false
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	$ColorRect/Label.text = str(Global.level_data["level1"]) + "/25"
func _on_body_entered(body):
	if body is Player: # Bezpieczniejsze sprawdzenie

		
		entered = true

func _on_body_exited(_body):
	entered = false

func _process(_delta):
	if entered and not teleporting:
		if Input.is_action_just_pressed("ui_accept"):
			teleporting = true
			if player:
				player.start_portal_effect(true) 
			$EnterTimer.start()
			

func _on_enter_timer_timeout():
	Global.restart_entire_run()
	Global.target_spawn_name = "MenuStart" 
	Global.spawn_position = Vector2(295, 405) 
	GlobalLoader.load_level("res://scenes/portal_one_menu.tscn") 
