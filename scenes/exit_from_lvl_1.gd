extends Area2D

@export_group("Ustawienia Przejścia")
@export_file("*.tscn") var target_scene_path: String # Wybierasz scenę z listy
@export var target_spawn_name: String = "DefaultSpawn" # Nazwa Markera w następnej scenie

var entered: bool = false
var teleporting: bool = false

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
	
	# Pobieramy gracza, żeby odpalić efekt
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.start_portal_effect(true)
		
	# Czekamy na animację
	await get_tree().create_timer(1.0).timeout
	
	# ZAPISUJEMY NAZWĘ PUNKTU W GLOBALU
	Global.target_spawn_name = target_spawn_name
	
	# Zmiana sceny
	get_tree().change_scene_to_file(target_scene_path)
	Global.returnLobby("level1")
