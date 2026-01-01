extends Area2D

@onready var player = get_tree().get_first_node_in_group("Player")
var health := 100
var dead := true
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Zapisujemy aktualną pozycję tego checkpointu do globalnej zmiennej
		Global.last_checkpoint_pos = global_position
		print("Checkpoint zapisany!")
		
