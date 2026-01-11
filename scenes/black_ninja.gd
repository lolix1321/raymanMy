extends Area2D
@export var blood_color: Color = Color.GREEN
@onready var start_pos = global_position
var max_health: int = 5
var health := max_health
var direction_x := 1
var speed := 60
var vignette_tween: Tween


func get_dmg(dmg, area):
	if area.is_in_group("pocisk"):
		health -= dmg
		
	var tween = create_tween() 
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.1)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)
	
func _on_area_entered(area: Area2D) -> void:
	get_dmg(1, area)
	area.queue_free()

func _on_head_shot_area_area_entered(area: Area2D) -> void:
	get_dmg(3, area)
	area.queue_free()
	
func _process(delta: float) -> void:
	update_health()
	check_death()
	position.x += speed * direction_x * delta
	
func check_death():
	if health <= 0:
		queue_free()

# --- KLUCZOWA ZMIANA TUTAJ ---
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body
		
		# 1. Sprawdzamy czy tarcza jest włączona (używając Twojej funkcji z gracza)
		var is_shielded = false
		if player.has_method("isShieldOnFunc"):
			is_shielded = player.isShieldOnFunc()
		
		# 2. Obsługa winiety (przekazujemy informację o tarczy)
		var vignette = get_tree().get_first_node_in_group("Vignette")
		if vignette:
			animate_vignette(vignette, is_shielded)
		
		# 3. Logika obrażeń - tylko jeśli tarcza NIE jest aktywna
		if not is_shielded:
			if player.has_method("get_damage"):
				player.get_damage(40)
			else:
				respawn_player(player)
		else:
			# Opcjonalnie: odrzuć moba w przeciwną stronę po uderzeniu w tarczę
			direction_x *= -1
			$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h

func animate_vignette(vignette: ColorRect, is_shielded: bool = false):
	var mat = vignette.material
	
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	
	vignette_tween = create_tween()
	
	# Jeśli tarcza aktywna, wymuś czarny kolor i wyjdź z funkcji
	if is_shielded:
		vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.1)
		vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.1)
		return 
	
	# Efekt obrażeń
	mat.set_shader_parameter("vignette_color", Color(1.0, 0.417, 0.348, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)

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

func update_health():
	var healthbar = $HealthBar
	healthbar.max_value = max_health
	healthbar.value = health
	healthbar.visible = health < max_health
	if direction_x < 0:
		$HealthBar.position.x = -20 
	elif direction_x > 0:
		$HealthBar.position.x = -14.0
		
func reset_position():
	global_position = start_pos
	health = max_health
