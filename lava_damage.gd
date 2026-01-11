extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		Global.player_died() 
		
		if Global.last_checkpoint_pos != Vector2.ZERO:
			body.global_position = Global.last_checkpoint_pos
			
			if body is CharacterBody2D:
				body.velocity = Vector2.ZERO
		else:
			body.global_position = Vector2(100, 500) 
			
			if body is CharacterBody2D:
				body.velocity = Vector2.ZERO
		body.die()
				
	


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("spider"):
		if area.has_method("kill"):
			area.kill()
