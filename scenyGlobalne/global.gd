extends Node

# Zmienne nawigacyjne
var spawn_position: Vector2 = Vector2.ZERO
var target_spawn_name: String = ""
var last_checkpoint_pos : Vector2 = Vector2.ZERO

# Zmienne wyniku
var permanent_diamonds = 0    # Ilość bezpiecznych diamentów
var temporary_diamonds = 0    # Ilość tymczasowych diamentów
var lobbyScore = 0




var permanent_collected_list: Array = [] 

var temp_collected_list: Array = []

var level_data = {
	"level1": 0,
	"level2": 2
}

signal diamonds_updated(new_amount)

func add_diamond(diamond_path: String):
	temporary_diamonds += 1
	
	temp_collected_list.append(diamond_path)
	
	diamonds_updated.emit(permanent_diamonds + temporary_diamonds)
	print("Zebrano: ", diamond_path, " | Razem: ", permanent_diamonds + temporary_diamonds)

func save_progress_at_checkpoint():
	permanent_diamonds += temporary_diamonds
	temporary_diamonds = 0
	
	
	permanent_collected_list.append_array(temp_collected_list)
	temp_collected_list.clear()
	


func player_died():
	
	
	temporary_diamonds = 0
	temp_collected_list.clear() 
	
	diamonds_updated.emit(permanent_diamonds)
	
	
	get_tree().reload_current_scene()

func restart_entire_run():
	print("Restart całej gry/runa")
	permanent_diamonds = 0
	temporary_diamonds = 0
	

	permanent_collected_list.clear()
	temp_collected_list.clear()
	
	diamonds_updated.emit(0)
	
	
	get_tree().reload_current_scene()

func returnLobby(nazwaLVL):
	if level_data.has(nazwaLVL) and level_data[nazwaLVL] <= temporary_diamonds:
		level_data[nazwaLVL] = temporary_diamonds
		lobbyScore = 0
		for diament in level_data.values():
			lobbyScore += diament
	print("Powrót do lobby...")
