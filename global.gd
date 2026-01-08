extends Node

var spawn_position: Vector2 = Vector2.ZERO
var target_spawn_name: String = ""
var last_checkpoint_pos : Vector2 = Vector2.ZERO
var permanent_diamonds = 0    # Te są bezpieczne (zapisane)
var temporary_diamonds = 0    # Te stracisz przy śmierci

var diamonds = 0
signal diamonds_updated(new_amount) # Sygnał informujący o zmianie

func add_diamond():
	temporary_diamonds += 1
	# Emitujemy sumę obu, żeby UI pokazywało całość
	diamonds_updated.emit(permanent_diamonds + temporary_diamonds)
	print("Zebrano diament tymczasowy. Suma: ", permanent_diamonds + temporary_diamonds)

func save_progress_at_checkpoint():
	# Gdy dotkniesz checkpointu, tymczasowe diamenty stają się stałe
	permanent_diamonds += temporary_diamonds
	temporary_diamonds = 0
	print("Postęp zapisany! Stałe diamenty: ", permanent_diamonds)

func player_died():
	print("Gracz zginął! Resetowanie tymczasowych diamentów...") 
	# Czyścimy tylko te, których nie dowieźliśmy do checkpointu
	temporary_diamonds = 0 
	diamonds_updated.emit(permanent_diamonds)
	
	# Resetujemy diamenty na mapie, które należały do grupy "Collectibles"
	get_tree().call_group("Collectibles", "reset_diamond")
