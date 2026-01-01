extends Area2D


func _process(delta: float) -> void: #lewitacja broni
	position.y += sin(Time.get_ticks_msec() / 200.0) * 10 * delta


func _on_body_entered(body: Node2D) -> void: #podnoszenie broni
	body.has_gun = true
	queue_free()
