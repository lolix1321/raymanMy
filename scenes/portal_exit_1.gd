# Skrypt wyjścia z portalu
extends Area2D

@export var target_scene_path: String = "res://scenes/level.tscn"
@export var spawn_position: Vector2 = Vector2.ZERO

var entered: bool = false
var teleporting: bool = false # Flaga, żeby nie odpalić teleportu kilka razy

func _on_body_entered(_body: PhysicsBody2D) -> void:
	if _body is Player:
		entered = true

func _on_body_exited(_body: PhysicsBody2D) -> void:
	if _body is Player:
		entered = false

func _process(_delta: float) -> void:
	if entered and not teleporting and Input.is_action_just_pressed("ui_accept"):
		start_teleportation()

func start_teleportation():
	teleporting = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.start_portal_effect(true)
		
	await get_tree().create_timer(1.0).timeout
	Global.spawn_position = spawn_position
	get_tree().change_scene_to_file(target_scene_path)
	
	
	
	
