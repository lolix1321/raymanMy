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
var sShieldOn: bool




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
	
	if !wasOnHead:
		$AnimatedSprite2D.flip_h = direction_x>0
	else:
		$AnimatedSprite2D.flip_h = direction_x<0
	
	if onplayer:
		global_position = player.global_position + Vector2(0, -20)
	elif jumping:
		var target_pos = player.global_position + Vector2(0, -20)
		global_position = global_position.move_toward(target_pos, speed * 2.0 * delta)
	elif falling:
		position.y += speed * 3 * delta
		if falling and $RayCast2D.is_colliding():
			falling = false
			rotation_degrees = 0 # Wraca dwo normalnej pozycji
	else:
		position.x += speed * direction_x * delta
		


func check_death():
	if health <= 0:
		queue_free()
		
		



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player_node = body #
		
		
		var shield_active = false
		if "sShieldOn" in player_node:
			shield_active = player_node.sShieldOn
		elif player_node.has_method("isShieldOnFunc"):
			shield_active = player_node.isShieldOnFunc()

		


		if shield_active:
			if jumping: 
				zrob_odrzut(player_node)
			else:
			   
				direction_x *= -1
				
			return #
		
		
		if not shield_active:
			var vignette = get_tree().get_first_node_in_group("Vignette")
			if vignette:
				animate_vignette(vignette)
		
		if not onplayer:
			if player_node.has_method("get_damage"):
				player_node.get_damage(10)
				
			else:
				respawn_player(player_node)
			
			
			

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
	if not body.is_in_group("Player") or body.is_in_group("Spider"):
		direction_x *= -1 
		


func _on_right_cliff_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player") or body.is_in_group("Spider"):
		direction_x *= -1 
		


func _on_left_cliff_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player") or body.is_in_group("Spider"):
		direction_x *= -1 
		
		
		
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
			
			# Oblicz kierunek
			var dir_x = sign(global_position.x - shield_marker.global_position.x)
			if dir_x == 0: dir_x = 1 
			
			# --- ETAP 1: ATAK ---
			var attack_tween = create_tween()
			attack_tween.tween_property(self, "global_position", shield_marker.global_position, 0.1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
			
			attack_tween.finished.connect(func():
				# --- ZMIANY TUTAJ ---
				var sila_odrzutu_x = 90 * dir_x  # Mocniejszy odrzut w bok
				var wysokosc_skoku = -25         # Dużo niżej (płaski skos)
				var czas_calowity = 0.35         # Szybsza animacja (bardziej dynamiczna)
				
				var start_pos = global_position
				var target_x = start_pos.x + sila_odrzutu_x
				var peak_y = start_pos.y + wysokosc_skoku
				
				# --- ETAP 2: PŁASKI ODRZUT ---
				
				# TWEEN X (Poziomo):
				# Używamy TRANS_CIRC lub CUBIC, żeby pająk szybko wystrzelił w bok
				var recoil_x_tween = create_tween()
				recoil_x_tween.set_parallel(true)
				recoil_x_tween.tween_property(self, "global_position:x", target_x, czas_calowity).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				
				# Rotacja (Szybszy obrót, bo krótszy czas)
				recoil_x_tween.tween_property(self, "rotation_degrees", 360 * dir_x, czas_calowity).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				
				# TWEEN Y (Pionowo - niski łuk):
				var recoil_y_tween = create_tween()
				
				# Szybki wyskok w górę (krótki impuls)
				recoil_y_tween.tween_property(self, "global_position:y", peak_y, czas_calowity * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				
				# Opadanie (nieco dłuższe, żeby było czuć "lądowanie")
				recoil_y_tween.tween_property(self, "global_position:y", start_pos.y, czas_calowity * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				
				
				var squash_tween = create_tween()
				scale = Vector2(0.6, 1.4) # Mocniejsze spłaszczenie przy uderzeniu
				squash_tween.tween_property(self, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

				
				recoil_y_tween.finished.connect(func():
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
		
		
		
		
func zrob_odrzut(target_player):
	
	jumping = false
	onplayer = false
	falling = false 
	
	
	var dir_x = sign(global_position.x - target_player.global_position.x)
	#if dir_x == 0: dir_x = 1
	
	
	var sila_odrzutu_x = 90 * dir_x 
	var wysokosc_skoku = -25         
	var czas_calowity = 0.35         
	
	var start_pos = global_position
	var target_x = start_pos.x + sila_odrzutu_x
	var peak_y = start_pos.y + wysokosc_skoku
	
	
	
	
	var recoil_x_tween = create_tween()
	recoil_x_tween.set_parallel(true)
	recoil_x_tween.tween_property(self, "global_position:x", target_x, czas_calowity).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	recoil_x_tween.tween_property(self, "rotation_degrees", 360 * dir_x, czas_calowity).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	
	var recoil_y_tween = create_tween()
	recoil_y_tween.tween_property(self, "global_position:y", peak_y, czas_calowity * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	recoil_y_tween.tween_property(self, "global_position:y", start_pos.y, czas_calowity * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	
	var squash_tween = create_tween()
	scale = Vector2(0.6, 1.4) 
	squash_tween.tween_property(self, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	
	recoil_y_tween.finished.connect(func():
		rotation_degrees = 0
		zeskocz()
	)
	
	
func kill():
	queue_free()
