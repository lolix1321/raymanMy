extends Area2D

# Możesz przypisać Marker2D w inspektorze
@export var spawn_point: Marker2D 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Wyświetla wiadomość w konsoli (Output)
		print("Gracz: ", body.name, " wypadł za mapę! Resetowanie pozycji... do markera")
		
		# Przenosimy gracza do pozycji markera
		if spawn_point:
			body.global_position = spawn_point.global_position
			
			# Opcjonalnie: jeśli gracz ma fizykę (CharacterBody2D), 
			# warto zresetować mu prędkość, żeby nie "leciał" dalej po teleportacji
			if body is CharacterBody2D:
				body.velocity = Vector2.ZERO
				print("Prędkość gracza została zresetowana.")
		else:
			# Jeśli nie przypisałeś markera, wróć do (0,0) lub wypisz błąd
			print("BŁĄD: Nie ustawiono spawn_point w inspektorze Area2D!")
