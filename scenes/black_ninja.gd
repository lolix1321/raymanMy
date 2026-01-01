extends Area2D

var health := 5
var direction_x := 1
var speed := 60
var vignette_tween: Tween
	
func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	var tween = create_tween() 
	# Naprawiłem tweena - teraz poprawnie mignie od 1.0 do 0.0
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.1)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)
	
func _process(delta: float) -> void:
	check_death()
	position.x += speed * direction_x * delta
	
func check_death():
	if health <= 0:
		queue_free()

# To służy do zadawania obrażeń graczowi
func _on_body_entered(body: Node2D) -> void:
	var vignette = get_tree().get_first_node_in_group("Vignette")
	if vignette:
		animate_vignette(vignette)
	if body.is_in_group("Player"):
		if body.has_method("get_damage"):
			body.get_damage(40)
		else:
			# Jeśli nie masz systemu HP, a chcesz żeby mob zabijał od razu:
			respawn_player(body)
			

func animate_vignette(vignette: ColorRect):
	var mat = vignette.material
	
	# Jeśli stary Tween jeszcze działa, natychmiast go zatrzymaj
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	
	vignette_tween = create_tween()
	
	# Ustawienie stanu początkowego (natychmiastowe)
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	
	# Płynny powrót
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)
	

# Funkcja pomocnicza do teleportacji gracza
func respawn_player(player: Node2D):
	if Global.last_checkpoint_pos != Vector2.ZERO:
		player.global_position = Global.last_checkpoint_pos
		if player is CharacterBody2D:
			player.velocity = Vector2.ZERO
	else:
		get_tree().reload_current_scene()
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		direction_x *= -1 
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h

func _on_right_cliff_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		direction_x *= -1 
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h


func _on_left_cliff_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		direction_x *= -1 
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
