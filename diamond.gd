extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Sprawdzamy czy to gracz (upewnij się, że gracz jest w grupie "Player")
	if body.is_in_group("Player"):
		Global.add_diamond() # Wywołujemy funkcję z Twojego skryptu global
		queue_free() # Diament znika po podniesieniu
