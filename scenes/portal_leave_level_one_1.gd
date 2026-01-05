extends Area2D

@export var target_scene_path: String = "res://scenes/portal_one_menu.tscn"
@export var spawn_position: Vector2 = Vector2.ZERO  # tu ustawiasz, gdzie ma się pojawić gracz

var entered: bool = false



func _on_body_entered(body: Node2D) -> void:
	entered = true


func _on_body_exited(body: Node2D) -> void:
	entered = false

func _process(_delta: float) -> void:
	if entered and Input.is_action_just_pressed("ui_accept"):
		teleport_player()
		
# --- Funkcja teleportacji ---
func teleport_player():
	# Ustawiamy pozycję w Global, aby Player mógł ją odebrać w _ready()
	Global.spawn_position = spawn_position
	# Zmieniamy scenę
	get_tree().change_scene_to_file(target_scene_path)
	
