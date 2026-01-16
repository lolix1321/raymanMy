extends Area2D

var max_health: int = 3 # TU USTAWIAJ HP
var health := max_health
var direction_x := 1
var speed := 100
var vignette_tween: Tween
var wasOnHead = false
var onplayer = false
@onready var player = get_tree().get_first_node_in_group('Player')
var jumping = false
var falling = false
var sShieldOn: bool 

# --- ZMIENNE DO LOGIKI ODBICIA ---
var pom = 1           # Licznik odbić (1 = może się odbić, 0 = już się nie odbije)
var is_bouncing = false # Blokada fizyki na czas animacji salta

func _process(delta: float) -> void:
	update_health()
	check_death()
	get_animation()
	
	# 1. JEŚLI PAJĄK LATA NA TWEENIE (ODBJA SIĘ), TO NIC INNEGO NIE RÓB
	if is_bouncing:
		return 

	# 2. WARUNEK ODBICIA
	# Jeśli ma jeszcze "pom" (1), gracz ma tarczę, a pająk spada lub siedzi
	if pom == 1 and player.isShieldOn and (falling or onplayer):
		odbij()
		return # Kończymy klatkę, żeby nie nakładać ruchu
	
	# --- STANDARDOWE RUCHY (wykonują się tylko, gdy is_bouncing == false) ---
	
	if !wasOnHead:
		$AnimatedSprite2D.flip_h = direction_x > 0
	else:
		$AnimatedSprite2D.flip_h = direction_x < 0
	
	if onplayer:
		if !player.spider:	
			player.spider = self
		global_position = player.global_position + Vector2(0, -20)
		
	elif jumping:
		var target_pos = player.global_position + Vector2(0, -20)
		global_position = global_position.move_toward(target_pos, speed * 2.0 * delta)
		
	elif falling:
		# Grawitacja działa dopiero jak is_bouncing się skończy
		position.y += speed * 3 * delta
		if falling and $RayCast2D.is_colliding():
			falling = false
			rotation_degrees = 0 # Wraca do normalnej pozycji po upadku
	else:
		# Zwykłe chodzenie
		position.x += speed * direction_x * delta


func odbij():
	
	if pom == 1:
		pom = 0          
		is_bouncing = true 
		print("pajak sei odbija")
		
		
		onplayer = false
		jumping = false
		falling = false
		wasOnHead = true
		
		if player and player.spider == self:
			player.spider = null

		
		var dir = sign(global_position.x - player.global_position.x)
		if dir == 0: dir = 1

		
		var t = create_tween().set_parallel(true)
		
		
		var target_pos = global_position + Vector2(40 * dir, -30)
		
		
		t.tween_property(self, "global_position", target_pos, 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		
		t.tween_property(self, "rotation_degrees", 360 * dir, 0.4)
		
		
		scale = Vector2(1.2, 0.8)
		t.tween_property(self, "scale", Vector2(1, 1), 0.4)\
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

		
		t.chain().tween_callback(func():
			rotation_degrees = 0
			is_bouncing = false 
			zeskocz() 
		)

func zeskocz():
	
	wasOnHead = true
	onplayer = false
	jumping = false
	falling = true 
	rotation_degrees = 0 
	if player and player.spider != null:
		player.spider = null
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h 



func _on_area_entered(area: Area2D) -> void:
	if area.has_method('bullet'):
		health -= 1
		area.queue_free()
		var tween = create_tween() 
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.1)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)

func get_animation():
	var animation = 'spider'
	if player.spider == self:
		animation = "spider_player"
	else:
		if onplayer:
			animation = "spider_player"
		if jumping:
			animation += "_jump"
		if falling:
			animation += "_jump2"
				
	$AnimatedSprite2D.animation = animation

func check_death():
	if health <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if jumping or onplayer: return 

		var player_node = body
		
		if player_node.isShieldOn:
			direction_x *= -1
			return
		
		if player_node.has_method("get_damage"):
			player_node.get_damage(10)

func animate_vignette(vignette: ColorRect):
	var mat = vignette.material
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	vignette_tween = create_tween()
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)

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

func _on_player_detector_body_entered(_body: Node2D) -> void:
	if not onplayer and not wasOnHead and player:
		jumping = true
		get_tree().create_timer(0.5).timeout.connect(func(): 
			if jumping:
				jumping = false
				onplayer = true
				wasOnHead = true
				player.spiderOnHeadFunc()
		)

func spider():
	pass

func _on_attack_timer_timeout() -> void:
	if onplayer:
		if player.spider == self:
			get_tree().get_first_node_in_group("Player").get_damage(10)
		else:
			player.spider.zeskocz()
			
func kill():
	queue_free()
