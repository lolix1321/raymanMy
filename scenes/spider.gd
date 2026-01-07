extends Area2D
var max_health:int = 3 # TU USTAWIAJ HP
var health := max_health
var direction_x := 1
var speed := 100
var vignette_tween: Tween
var wasOnHead = false
var onplayer = false
@onready var player = get_tree().get_first_node_in_group('Player')
var jumping = false


func _on_area_entered(area: Area2D) -> void:
	if area.has_method('bullet'):
		health -= 1
		area.queue_free()
		var tween = create_tween() 
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.1)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)



var falling = false

func zeskocz():
	wasOnHead = true
	onplayer = false
	jumping = false
	falling = true
	rotation_degrees = 0 # Obraca go do góry nogami
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h 
	
func get_animation():
	var animation = 'spider'
	if onplayer:
		animation = "spider_player"
	if jumping:
		animation += "_jump"
	if falling:
		animation += "_jump2"
	$AnimatedSprite2D.animation = animation


func _process(delta: float) -> void:
	update_health()
	check_death()
	get_animation()
	
	if onplayer:
		global_position = player.global_position + Vector2(0, -20)
	elif jumping:
		global_position = global_position.move_toward(player.global_position, speed * 2.0 * delta)
	elif falling:
		position.y += speed * 1 * delta
		if falling and $RayCast2D.is_colliding():
			falling = false
			rotation_degrees = 0 # Wraca do normalnej pozycji
	else:
		position.x += speed * direction_x * delta
		


func check_death():
	if health <= 0:
		queue_free()
		
		



func _on_body_entered(body: Node2D) -> void:
	var vignette = get_tree().get_first_node_in_group("Vignette")
	if vignette:
		animate_vignette(vignette)
	if body.is_in_group("Player"):
		if !onplayer:
			if body.has_method("get_damage"):
				body.get_damage(10)
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



func respawn_player(player: Node2D):
	if Global.last_checkpoint_pos != Vector2.ZERO:
		player.global_position = Global.last_checkpoint_pos
		if player is CharacterBody2D:
			player.velocity = Vector2.ZERO
	else:
		get_tree().reload_current_scene()

func _on_border_area_body_entered(body: Node2D) -> void:
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
		
		
func update_health():
	var healthbar = $HealthBar
	healthbar.max_value = max_health
	healthbar.value = health
	healthbar.visible = health < max_health
	#if direction_x < 0:
		#$HealthBar.position.x = -20 
	#elif direction_x > 0:
		#$HealthBar.position.x = -14.0 

func _on_player_detector_body_entered(_body: Node2D) -> void:
	if not onplayer and not wasOnHead:
		if player and player.isShieldOnFunc():
			jumping = false
			
			var shield_marker = player.get_node("ShieldPoint")
			
			
			var dir_x = sign(global_position.x - shield_marker.global_position.x)
			if dir_x == 0: dir_x = 1 
			
			
			var attack_tween = create_tween()
			
			attack_tween.tween_property(self, "global_position", shield_marker.global_position, 0.1).set_trans(Tween.TRANS_SINE)
			
			
			attack_tween.finished.connect(func():
				
				var recoil_tween = create_tween()
				
				var sila_odrzutu = 40 
				var wysokosc_skoku = -30
				
				
				var recoil_pos = global_position + Vector2(dir_x * sila_odrzutu, wysokosc_skoku)
				
				
				recoil_tween.parallel().tween_property(self, "global_position", recoil_pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				recoil_tween.parallel().tween_property(self, "rotation_degrees", 360 * dir_x, 0.3)
				
				
				recoil_tween.finished.connect(func():
					rotation_degrees = 0
					zeskocz()
				)
			)
			
		else:
			
			jumping = true
			get_tree().create_timer(0.5).timeout.connect(func(): 
				if jumping:
					jumping = false
					onplayer = true
					wasOnHead = true
					rotation_degrees = 0
					player.spiderOnHeadFunc()
			)

func spider():
	pass


func _on_attack_timer_timeout() -> void:
	if onplayer:
		get_tree().get_first_node_in_group("Player").get_damage(10)
