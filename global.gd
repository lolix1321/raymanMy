extends Node

var spawn_position: Vector2 = Vector2.ZERO
var target_spawn_name: String = ""
var last_checkpoint_pos : Vector2 = Vector2.ZERO
var permanent_diamonds = 0    # Te są bezpieczne (zapisane)
var temporary_diamonds = 0    # Te stracisz przy śmierci


var current_level_name = "level1"
var lobbyScore = 0

var level_data = {
	"level1": 0,
	"level2": 2
}


signal diamonds_updated(new_amount) 

func add_diamond():
	temporary_diamonds += 1
	
	diamonds_updated.emit(permanent_diamonds + temporary_diamonds)
	print("Zebrano diament tymczasowy. Suma: ", permanent_diamonds + temporary_diamonds)

func save_progress_at_checkpoint():
	
	permanent_diamonds += temporary_diamonds
	temporary_diamonds = 0
	
   
	get_tree().call_group("Collectibles", "make_permanent")
	
	
	print("Postęp zapisany! Stałe diamenty: ", permanent_diamonds)

func player_died():
	print("Gracz zginął! Resetowanie tymczasowych diamentów...") 
	
	
	
	temporary_diamonds = 0 
	diamonds_updated.emit(permanent_diamonds)
	
	
	get_tree().call_group("Collectibles", "reset_diamond")


func returnLobby(nazwaLVL):
	if level_data[nazwaLVL]<=temporary_diamonds:
		level_data[nazwaLVL] = temporary_diamonds
		lobbyScore = 0
		for diament in level_data.values():
			lobbyScore += diament
	
	
	
	print("test")
	
func _process(delta: float) -> void:
	print(temporary_diamonds)
	
