
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if Global.last_checkpoint_pos != Vector2.ZERO:
			# Teleportujemy gracza do checkpointu
			body.global_position = Global.last_checkpoint_pos
			
			# Opcjonalnie: jeśli gracz ma fizykę, warto wyzerować mu prędkość, 
			# żeby nie "wyleciał" z checkpointu z prędkością, którą miał wpadając w lawę
			if body is CharacterBody2D:
				body.velocity = Vector2.ZERO
		else:
			# Co jeśli gracz nie dotknął żadnego checkpointu? 
			# Możesz go przenieść na start poziomu (ustal ręcznie pozycję)
			body.global_position = Vector2(100, 500) # Przykładowe współrzędne startu
	
