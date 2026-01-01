extends Area2D

var health := 100

@onready var player = get_tree().get_first_node_in_group("Player")
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body_entered:
		queue_free()
		
	
