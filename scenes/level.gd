extends Node2D

const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var levels = ["res://scenes/portal_one_menu.tscn", "res://scenes/level_2.tscn"]
func _ready() -> void:
	get_tree().get_first_node_in_group("Player").can_use_shield = false
	get_tree().get_first_node_in_group("diamondLabel").maxDiamenty = 100
	Global.temporary_diamonds = Global.lobbyScore
	get_tree().get_first_node_in_group("diamondLabel").wyswietlijDiamenty()
	



func _on_player_shoot(pos, facing_right) -> void:
	var bullet = bullet_scene.instantiate()
	var direction = 1 if facing_right else -1
	bullet.direction = direction
	$Bullets.add_child(bullet)
	bullet.position = pos + Vector2(12 * direction, 2)
