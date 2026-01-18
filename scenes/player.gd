extends CharacterBody2D

class_name Player
var stamina = 50.0       
var max_stamina = 50.0    
var stamina_drain = 20.0   
var stamina_regen = 10.0  
var can_sprint = true  
@onready var health := 100
var is_teleporting := false
var vignette_tween: Tween
var speed := 1120
var direction_x := 0.0
var direction_y := 0.0
var facing_right := true
var has_diamond := false
var has_gun := false
var can_shoot := true
var vulnerable := true

var can_regenerate := false 
@onready var dead := false
@onready var entered = false
@onready var shield_bar = $shieldBarCanv/shieldBar # Dostosuj ścieżkę do swojego paska tarczy
@onready var shield_label = $shieldBarCanv/ShieldTimerLabel # Dostosuj ścieżkę

var isDying = false
var can_animate = true


var spider
var duch

var isShieldOn = false
var can_use_shield = true
var isHittedDuringShield = false

var isGhostInside = false


signal shoot(pos: Vector2, direction: bool)


@onready var camera_target = $CameraTarget
var cam_stick_dist = 60.0

func isShieldOnFunc():
	return isShieldOn


	
func _ready():
	
	
	
	
	$CooldownBar.visible = false
	shield_bar.visible = true # Pasek tarczy ma być widoczny
	shield_bar.max_value = 10.0 # Standardowy cooldown
	shield_bar.value = 10.0     # Na start tarcza jest gotowa (pełna)
	if $AnimatedSprite2D.material:
		$AnimatedSprite2D.material.set_shader_parameter("amount", 0.0)
	
	if Global.target_spawn_name != "":
		Global.last_checkpoint_pos = Vector2.ZERO 
		set_player_to_spawn.call_deferred()
		
	elif Global.last_checkpoint_pos != Vector2.ZERO:
		global_position = Global.last_checkpoint_pos
		
		
	elif Global.spawn_position != Vector2.ZERO:
		global_position = Global.spawn_position
		# TUTAJ DODAJEMY EFEKT:
		start_portal_effect(false) 
		Global.spawn_position = Vector2.ZERO
	get_tree().call_group("diamondLabel", "wyswietlijDiamenty")
		

func set_player_to_spawn():
	var spawn_node = get_tree().current_scene.find_child(Global.target_spawn_name, true, false)
	if spawn_node:
		# Resetujemy prędkość, żeby postać "nie wleciała" w nową scenę z pędem
		if self is CharacterBody2D:
			velocity = Vector2.ZERO
			
		global_position = spawn_node.global_position
		
		
		if $AnimatedSprite2D.material:
			$AnimatedSprite2D.material.set_shader_parameter("amount", 0.0)
		start_portal_effect(false)
		Global.target_spawn_name = ""
		
var jumpCounter:int  = 0

func spiderOnHeadFunc():
		
	if !isShieldOn:
		$ShieldArea/cooldownTarczy.paused = true
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpCounter += 1
		print(jumpCounter)
		
	if jumpCounter >= 2:
		if spider:
			spider.zeskocz()
			$ShieldArea/cooldownTarczy.paused = false
			jumpCounter = 0 
		

const JUMP_FORCE = -600.0        # Siła wybicia (startowa)


const GRAVITY_RISING = 400.0     # Lekka grawitacja (jak trzymasz spację i lecisz w górę)
const GRAVITY_FALLING = 1000.0   # Ciężka grawitacja (jak spadasz lub puściłeś spację)

const SPEED_WALK = 160.0        
const SPEED_SPRINT = 250.0      



func _physics_process(delta: float) -> void:
	var target_stick_x = 0.0
	if direction_x > 0:
		target_stick_x = cam_stick_dist
	elif direction_x < 0:
		target_stick_x = -3*cam_stick_dist
	else:
		target_stick_x = camera_target.position.x

	camera_target.position.x = lerp(camera_target.position.x, target_stick_x, 2.0 * delta)
	
	cooldownAnim()
	shieldCooldownAnim()	
	if spider: spiderOnHeadFunc()
	if isGhostInside:
		
		if isShieldOn:
			isShieldOn = false
			$ShieldArea/AnimatedSprite2D.visible = false
			can_use_shield = false
			$ShieldArea/trwanieTarczy.stop()
			$ShieldArea/cooldownTarczy.start()
		else:
			$ShieldArea/cooldownTarczy.paused = false
			
	if is_teleporting:
		velocity = Vector2.ZERO
		direction_x = 0
		set_anim('jump')
		move_and_slide()
		return


	var current_gravity = GRAVITY_FALLING 


	if velocity.y < 0 and Input.is_action_pressed("jump"):
		
		current_gravity = GRAVITY_RISING
	

	velocity.y += current_gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	var current_speed = SPEED_WALK
	if Input.is_action_pressed("Sprint") and stamina > 0 and can_sprint:
		current_speed = SPEED_SPRINT
		stamina -= stamina_drain * delta
		if stamina <= 0:
			stamina = 0
			can_sprint = false
			current_speed = SPEED_WALK
	else:
		current_speed = SPEED_WALK
		if stamina < max_stamina:
			stamina += stamina_regen * delta
		if stamina >= 20:
			can_sprint = true

	get_input()
	velocity.x = direction_x * current_speed
	
	move_and_slide()

	if can_animate:
		get_animation()
	
	get_facing_direction()
func get_input():
	direction_x = Input.get_axis("left", "right")
	
	shield()
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -230
		
		

		
	if Input.is_action_just_pressed("shoot") and can_shoot and has_gun and not isGhostInside:
		shoot.emit(global_position, facing_right)
		can_shoot = false
		$Timers/CooldownTimer.start()
		$Timers/FireTimer.start()
		$Fire.get_child(facing_right).show()
		
	if Input.is_action_just_pressed("Sprint") and is_on_floor():
		speed = 150
	if Input.is_action_just_released("Sprint"):
		speed = 120
	
		

	
func get_animation():
	var animation = 'idle'
	if not is_on_floor():
		animation = 'jump'
	elif direction_x != 0:
		animation = 'walk'
	if has_gun:
		animation += "_gun"
	if spider:
		animation += "_spider"
		
			
	if isDying:
		animation = "_gun"
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.flip_h = not facing_right
	
func get_facing_direction():
	if direction_x != 0:
		facing_right = direction_x >= 0
		
		
	
func get_damage(amount):
	if vulnerable:
		
		if isShieldOn:
			amount = 0
			isHittedDuringShield = true
			isShieldOn = false
			$ShieldArea/AnimatedSprite2D.visible = false
			can_use_shield = false
			$ShieldArea/trwanieTarczy.stop()
			$ShieldArea/cooldownTarczy.start()
			
			
		health -= amount
		
		animate_vignette()
		can_regenerate = false    
		$Timers/GainHealth.stop()  
		$Timers/WaitTimer.start(3.0)
		vulnerable = false
		$Timers/InvicibilityTimer.start()
		var tween = create_tween() 
		tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",1.0,0.0) 
		tween.tween_property($AnimatedSprite2D,"material:shader_parameter/amount",0.0,0.1).set_delay(0.1) 
		if health <= 0:
			die()


		
func die():
	$ShieldArea/AnimatedSprite2D.visible = false
	if isDying: return
	isDying = true
	health = 0
	$Timers/GainHealth.stop()
	# Zamrożenie postaci
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	var sprite = $AnimatedSprite2D
	if sprite.material is ShaderMaterial:
		var mat = sprite.material
		var death_tween = create_tween()
		
		# --- DŁUŻSZA ANIMACJA ---
		# Błysk bieli (szybki start, wolne wygasanie)
		death_tween.parallel().tween_property(mat, "shader_parameter/amount", 1.0, 0.1)
		death_tween.parallel().tween_property(mat, "shader_parameter/amount", 0.0, 1.5).set_delay(0.2)
		
		# Rozpad (wydłużony do 2 sekund dla lepszego efektu)
		# TRANS_QUAD_OUT sprawi, że na początku wybuchną szybko, a potem zwolnią
		death_tween.parallel().tween_property(mat, "shader_parameter/glitch_chance", 1.0, 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	
	
	# Start zaciemnienia ekranu (możesz też wydłużyć tę animację w AnimationPlayerze)
	if Transition.has_node("AnimationPlayer"):
		# Możesz dodać opóźnienie do animacji Transition, żeby najpierw było widać wybuch
		await get_tree().create_timer(0.7).timeout 
		Transition.get_node("AnimationPlayer").play("death_animation")
	
	# CZEKAMY DŁUŻEJ: suma czasu wybuchu (np. 2-2.5 sekundy)
	await get_tree().create_timer(0.6).timeout

	# Reset parametrów przed reloadem
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("glitch_chance", 0.0)
		sprite.material.set_shader_parameter("amount", 0.0)
	if duch:
		duch.znikanieEfektu()
	

	Global.player_died() #GLOBAL TERAZ RESETUJE SCENE TU NIE RESETOWAC!
	health = 100 
	
	

func animate_vignette():
	var vignette = get_tree().get_first_node_in_group("Vignette")
	if not vignette: return
	
	var mat = vignette.material
	
	# Jeśli leci poprzedni tween, ubijamy go
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	
	vignette_tween = create_tween()
	
	# --- ZMIANA TUTAJ ---
	# Sprawdzamy czy tarcza jest włączona. 
	# Użyj 'player.sShieldOn' lub samej zmiennej 'sShieldOn' w zależności gdzie ona jest.
	if isShieldOn: 
		# Jeśli tarcza jest on: Szybki powrót do normalnego koloru (czarny) i rozmiaru
		vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.1)
		vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.1)
		return # Kończymy funkcję, nie robimy czerwonego błysku
	
	# --- EFEKT OBRAŻEŃ (Tylko gdy tarcza wyłączona) ---
	
	# Natychmiast czerwień (uderzenie)
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	
	# Powrót do czerni (zanikanie bólu)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)

func _on_cooldown_timer_timeout() -> void:
	$CooldownBar.visible = false
	can_shoot = true


func _on_fire_timer_timeout() -> void:
	for child in $Fire.get_children():
		child.hide()
		
func _on_jump_timer_timeout() -> void:
	for child in $jumpAnimation.get_children():
		child.show()
		
func _on_jump_timer_end_timeout() -> void:
	for child in $jumpAnimation.get_children():
		child.hide()



func _on_invicibility_timer_timeout() -> void:
	vulnerable = true


func start_portal_effect(entering: bool):
	is_teleporting = true 
	can_shoot = false
	velocity = Vector2.ZERO 
	
	var tween = create_tween()
	if entering:
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 1.0)
	else:
		$AnimatedSprite2D.material.set_shader_parameter("amount", 1.0)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 1.0)

	$Timers/PortalTimer.wait_time = 1.0
	$Timers/PortalTimer.start()
	
func _on_portal_timer_timeout() -> void:
	is_teleporting = false
	can_shoot = true



func _on_wait_timer_timeout() -> void:
	can_regenerate = true
	$Timers/GainHealth.start(1.0) 
	


func _on_gain_health_timeout() -> void:
	if can_regenerate and health < 100:
		health = min(health + 10, 100) 
		
		if health >= 100:
			$Timers/GainHealth.stop()

			
			


func zmianaCanAnimate():
	can_animate = !can_animate


func set_anim(anim: String):
	
	if has_gun:
		anim += "_gun"
	$AnimatedSprite2D.animation = anim
	$AnimatedSprite2D.flip_h = not facing_right
	
	

func cooldownAnim():
	if !$Timers/CooldownTimer.is_stopped():
		var timer = $Timers/CooldownTimer
		var coolDownBar = $CooldownBar
		var _left = $Timers/CooldownTimer.time_left
		coolDownBar.visible = true
		
		
		coolDownBar.max_value = timer.wait_time
		coolDownBar.value = timer.time_left
		

			


var used_spiders: Array = [] 

func _on_colision_area_entered(area: Area2D) -> void:
	if area.has_method("spider") and not area in used_spiders:
		spider = area
		used_spiders.append(area) 


func shield():
	
	if Input.is_action_just_pressed("shield") and can_use_shield and not isShieldOn and not isHittedDuringShield and not spider and not isGhostInside: #and not spider
		isShieldOn = true
		$ShieldArea/AnimatedSprite2D.visible = true
		$ShieldArea/trwanieTarczy.start()
		
	
	
	
		
	


func _on_cooldown_tarczy_timeout() -> void:
	can_use_shield = true
	isHittedDuringShield = false


func _on_trwanie_tarczy_timeout() -> void:
	isShieldOn = false
	$ShieldArea/AnimatedSprite2D.visible = false
	can_use_shield = false
	$ShieldArea/cooldownTarczy.start()
	
	
func shieldCooldownAnim():
	var cd_timer = $ShieldArea/cooldownTarczy 
	var trwanie_timer = $ShieldArea/trwanieTarczy
	
	# Resetowanie efektów (ważne, aby tarcza nie została rozjaśniona po użyciu)
	shield_bar.modulate = Color(1, 1, 1, 1)
	shield_label.scale = Vector2(1, 1) # Reset skali napisu, jeśli wcześniej był używany
	
	if not trwanie_timer.is_stopped():
		# TARCZA AKTYWNA
		shield_bar.max_value = trwanie_timer.wait_time
		shield_bar.value = trwanie_timer.time_left
		shield_label.visible = true
		shield_label.text = str(snapped(trwanie_timer.time_left, 0.1)) + "s"
		shield_label.modulate = Color(0.173, 1.0, 1.0, 1.0)

	elif not cd_timer.is_stopped():
		# TARCZA ŁADUJE SIĘ
		shield_bar.max_value = cd_timer.wait_time
		shield_bar.value = cd_timer.wait_time - cd_timer.time_left
		shield_label.visible = true
		shield_label.text = str(snapped(cd_timer.time_left, 0.1)) + "s"
		shield_label.modulate = Color(1, 1, 1)
		
	else:
		# TARCZA GOTOWA
		shield_bar.max_value = 1.0
		shield_bar.value = 1.0
		shield_label.visible = true
		shield_label.text = "READY!"
		shield_label.modulate = Color(0.173, 1.0, 1.0, 1.0)
		
		# --- TYLKO EFEKT PULSOWANIA ŚWIATŁEM ---
		var speed = 5.0 
		var intensity_light = 0.5 # Zwiększyłem odrobinę dla lepszego efektu
		
		var time = Time.get_ticks_msec() * 0.001
		var sin_wave = (sin(time * speed) + 1.0) * 0.5 # Mapowanie sinusa z (-1 do 1) na (0 do 1)
		
		# Obliczanie jasności
		var light_value = 1.0 + (sin_wave * intensity_light)
		
		# Nakładamy kolor (rozjaśniamy bazowy kolor tarczy)
		shield_bar.modulate = Color(light_value, light_value, light_value)
		# Jeśli chcesz, żeby napis też pulsował światłem, odkomentuj poniższą linię:
		shield_label.modulate = Color(0.173 * light_value, 1.0 * light_value, 1.0 * light_value)

		




func duszek(duszek):
	duch = duszek
	
