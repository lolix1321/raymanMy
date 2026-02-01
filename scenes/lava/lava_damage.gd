extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("die"):
		# 1. Sprawdzamy, czy gracz już nie jest w trakcie umierania
		if body.isDying: return 
		
		# 2. Wywołujemy funkcję die(), która uruchamia glitch i Transition (ciemny ekran)
		body.die()
		
		# 3. Czekamy na moment, w którym ekran jest już czarny.
		# Zakładając, że Twoja animacja w Transition trwa ok. 0.6 - 0.8s:
		await get_tree().create_timer(1.5).timeout
		
		# 4. DOPIERO TERAZ teleportujemy gracza (gdy gracz nic nie widzi)
		teleport_to_checkpoint(body)

func teleport_to_checkpoint(body: Node2D):
	if Global.last_checkpoint_pos != Vector2.ZERO:
		body.global_position = Global.last_checkpoint_pos
	else:
		body.global_position = Vector2(100, 500) 
	
	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("spider"):
		if area.has_method("kill"):
			area.kill()
