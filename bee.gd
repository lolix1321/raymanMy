extends Area2D

var max_health: int = 6
var health := max_health
var speed := 60
var szybkoscGonieniaGracza:int = 160
var is_shaking: bool = false
var knockback_velocity := Vector2.ZERO
var knockback_strength := 300.0
var can_attack := true
var vignette_tween: Tween
@onready var target = marker2
var isInPlayer = false
@export var marker1: Marker2D
@export var marker2: Marker2D
var dmg_power = 0.1
var chromatic_tween: Tween
var forward := true
@onready var player = get_tree().get_first_node_in_group('Player')
@export var notice_radius := 120
var escape_timer := 0.0
var escaping: bool = false
var ischasing = false
var isDying = false



func _ready():
	print("test")
	position = marker1.position

func _process(delta):
	
	# LOGIKA ŚMIERCI I RUCHU KNOCKBACK (musi działać zawsze)
	if knockback_velocity.length() > 20:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	
	if isDying:
		return # Jeśli umiera, nie wykonujemy reszty logiki (pogoni, ataku itp.)

	# LOGIKA DLA ŻYWEGO DUCHA
	check_death()
	get_target()
	#update_health() - chyba lepiej bez 
	
	if ischasing and not isDying:
		var camera = get_viewport().get_camera_2d()
		if camera:
			var intensity = 2.0
			# Dodajemy wstrząs do ISTNIEJĄCEGO offsetu, a potem go cofamy
			var shake = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
			camera.offset += shake
			
			# Bardzo ważne: po narysowaniu klatki silnik zaktualizuje pozycję, 
			# ale musimy odjąć ten wstrząs w następnej klatce, żeby nie "odpłynęła".
			# Dlatego lepiej użyć bezpieczniejszej metody poniżej:
			
			await get_tree().process_frame
			if camera:
				camera.offset -= shake
	
	if ischasing:
		if not isDying: 
			$AnimatedSprite2D.play("animacja_lecenia")
		$AnimatedSprite2D/HealthBar.visible = false
		
		if $TimerDoZnikniecia.is_stopped():
			$TimerDoZnikniecia.start()
	
	if isInPlayer:
		scary_shake_behavior(delta)
		$AnimatedSprite2D/HealthBar.visible = false
		player.isGhostInside = true
		return 
	
	if position.distance_to(player.position) <= 5 and escaping == false: 
		escaping = true
		escape_timer = 0.4
		forward = !forward 
		
	if escaping:
		escape_timer -= delta
		if escape_timer <= 0:
			escaping = false
		target = marker2 if forward else marker1
	
	# Normalny ruch (tylko gdy nie ma dużego knockbacku)
	if knockback_velocity.length() <= 20:
		position += (target.position - position).normalized() * speed * delta
	
	flip_logic()

func get_target():
	if forward and position.distance_to(marker2.position) < 10 or\
	   not forward and position.distance_to(marker1.position) < 10:
		forward = not forward
		
	# Sprawdzamy, czy duch właśnie TERAZ zaczyna gonić (moment przejścia)
	var distance_to_player = position.distance_to(player.position)
	if (distance_to_player < notice_radius and not escaping and not overlaps_body(player)) or ischasing:
		
		# JEŚLI TO PIERWSZY MOMENT POGONI:
		if not ischasing:
			ischasing = true
			start_chromatic_effect(true, false) # Włączamy efekt
			
		target = player
		ischasing = true
		speed = szybkoscGonieniaGracza
	elif forward:
		target = marker2
	else:
		target = marker1
	

func start_chromatic_effect(on: bool, is_inside: bool = false):
	if isDying and on: return
	var filter = get_tree().get_first_node_in_group("ChromaticFilter")
	if not filter: return
	
	if chromatic_tween:
		chromatic_tween.kill()
	chromatic_tween = create_tween() 
	
	if on:
		if is_inside:
			chromatic_tween.set_loops()
			chromatic_tween.tween_property(filter.material, "shader_parameter/amount", 4.5, 0.3).set_trans(Tween.TRANS_SINE)
			chromatic_tween.tween_property(filter.material, "shader_parameter/amount", 2.0, 0.3).set_trans(Tween.TRANS_SINE)
		else:
			chromatic_tween.tween_property(filter.material, "shader_parameter/amount", 2.0, 2.0).set_trans(Tween.TRANS_SINE)
	else:
		chromatic_tween.tween_property(filter.material, "shader_parameter/amount", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	
func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.1)
	
func flip_logic():
	$AnimatedSprite2D.flip_h = not forward
	if position.distance_to(player.position) < notice_radius or ischasing:
		$AnimatedSprite2D.flip_h = position.x < player.position.x
		
func check_death():
	if health <= 0:
		umieranieDucha() # Wywołujemy animację zamiast znikania od razu

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and can_attack and player.isShieldOn and not isInPlayer:
		umieranieDucha()
	elif body.is_in_group("Player") and not player.isShieldOn:
		if not isInPlayer:
			isInPlayer = true
			start_chromatic_effect(true, true) # 'true' włącza pulsowanie

func animate_vignette(vignette: ColorRect):
	var mat = vignette.material
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	
	vignette_tween = create_tween()
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)
	
#func update_health():
	#var healthbar = $AnimatedSprite2D/HealthBar
	#healthbar.max_value = max_health
	#healthbar.value = health
	#healthbar.visible = health < max_health
	 
func scary_shake_behavior(delta):
	player.duszek(self)
	var frequency = 15.0 
	var amplitude = 10.0 
	
	var offset = Vector2(
		sin(Time.get_ticks_msec() * 0.01 * frequency) * amplitude,
		cos(Time.get_ticks_msec() * 0.012 * frequency) * amplitude
	)
	
	var shake = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	position = player.position + offset + shake
	
	if can_attack and player:
		if player.has_method("get_damage"):
			player.get_damage(dmg_power)
		var vignette = get_tree().get_first_node_in_group("Vignette")
		if vignette:
			animate_vignette(vignette)
		can_attack = false
		await get_tree().create_timer(0.2).timeout
		can_attack = true

func _on_timer_do_znikniecia_timeout() -> void:
	umieranieDucha()
	
func umieranieDucha():
	if isDying: return
	isDying = true
	$AnimatedSprite2D.play("animacja_umierania")
	
	start_chromatic_effect(false)
	isInPlayer = false
	if player:
		player.isGhostInside = false
		var bounce_direction = (global_position - player.global_position).normalized()
		knockback_velocity = bounce_direction * (knockback_strength * 1.5) 
	
	
	speed = 0 
	
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 1.5) # Powolne znikanie
	
	await get_tree().create_timer(4.0).timeout
	queue_free()
	
	
func znikanieEfektu():
	var filter = get_tree().get_first_node_in_group("ChromaticFilter")
	if not filter: return
	if chromatic_tween: chromatic_tween.kill()
	filter.material.set_shader_parameter("amount", 0.0)
