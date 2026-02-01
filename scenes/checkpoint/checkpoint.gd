extends Area2D

@onready var checkpoint_label: Label = $CheckpointUI/CheckpointLabel
@export var is_starting_checkpoint: bool = false 

var was_activated: bool = false 

func _ready() -> void:
	if checkpoint_label:
		checkpoint_label.modulate.a = 0
		checkpoint_label.visible = false
	
	
	var dist = Global.last_checkpoint_pos.distance_to(global_position)
	
	
	if dist < 20: #odradzanie
		was_activated = true 
		checkpoint_label.text = "TRY AGAIN"
		show_checkpoint_animation()

	
	elif is_starting_checkpoint:
		was_activated = true 

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Player") and not was_activated:
		
		Global.last_checkpoint_pos = global_position
		Global.save_progress_at_checkpoint()
		
		
		
		
		checkpoint_label.text = "CHECKPOINT"
		show_checkpoint_animation()

		was_activated = true 

func show_checkpoint_animation() -> void:
	if not checkpoint_label:
		return
	
	
	checkpoint_label.visible = true
	checkpoint_label.modulate.a = 0
	
	var tween = create_tween()
	# Pojawianie się (0.4s)
	tween.tween_property(checkpoint_label, "modulate:a", 1.0, 0.4)
	# Czekanie (1.5s)
	tween.tween_interval(1.5)
	# Znikanie (0.6s)
	tween.tween_property(checkpoint_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): checkpoint_label.visible = false)
