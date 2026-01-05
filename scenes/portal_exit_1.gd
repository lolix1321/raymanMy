
extends Area2D

var entered := false
var teleporting := false
var pomocniczazmiennadokurwateleportacjizlobbydolevela:int = 0
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(body):
	
	if body is Player: # Bezpieczniejsze sprawdzenie
		print("hello world")
		entered = true
		if pomocniczazmiennadokurwateleportacjizlobbydolevela == 0:
			get_tree().get_first_node_in_group("Player").zmianaCanAnimate()
			get_tree().get_first_node_in_group("Player").set_anim('jump')
			
			print("tluste dupsko")
			pomocniczazmiennadokurwateleportacjizlobbydolevela+=1
			get_tree().get_first_node_in_group("Player").start_portal_effect(true)
			$TimerZebyDzialalo.start()
			

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
	Global.target_spawn_name = "MenuStart" 
	Global.spawn_position = Vector2(295, 405) 
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_timer_zeby_dzialalo_timeout() -> void:
	get_tree().get_first_node_in_group("Player").start_portal_effect(false)
	get_tree().get_first_node_in_group("Player").zmianaCanAnimate()
