extends Area2D

@onready var checkpoint_label: Label = $CheckpointUI/CheckpointLabel

# Nowa zmienna, którą zaznaczysz w Inspektorze dla pierwszego checkpointa
@export var is_starting_checkpoint: bool = false 

var was_activated: bool = false 

func _ready() -> void:
	if checkpoint_label:
		checkpoint_label.modulate.a = 0
		checkpoint_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not was_activated:
		Global.last_checkpoint_pos = global_position
		
		# KLUCZOWA ZMIANA:
		Global.save_progress_at_checkpoint()
		
		print("Nowy checkpoint zapisany i diamenty zabezpieczone!")
		
		was_activated = true 
		if not is_starting_checkpoint:
			show_checkpoint_animation()

func show_checkpoint_animation() -> void:
	if not checkpoint_label:
		return
		
	var tween = create_tween()
	checkpoint_label.visible = true
	checkpoint_label.modulate.a = 0
	
	tween.tween_property(checkpoint_label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.0)
	tween.tween_property(checkpoint_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): checkpoint_label.visible = false)
	
	
