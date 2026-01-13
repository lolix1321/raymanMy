extends Node2D


const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	get_tree().get_first_node_in_group("Player").can_use_shield = true
	get_tree().get_first_node_in_group("diamondLabel").maxDiamenty = 25
	Global.temporary_diamonds = 0
	get_tree().get_first_node_in_group("diamondLabel").wyswietlijDiamenty()
	
	



func _on_player_shoot(pos, facing_right) -> void:
	var bullet = bullet_scene.instantiate()
	var direction = 1 if facing_right else -1
	bullet.direction = direction
	$Bullets.add_child(bullet)
	bullet.position = pos + Vector2(14 * direction, 5)
