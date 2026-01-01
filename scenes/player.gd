extends CharacterBody2D

class_name Player
var stamina = 50.0       
var max_stamina = 50.0    
var stamina_drain = 20.0   
var stamina_regen = 10.0  
var can_sprint = true  
@onready var health := 100
var is_teleporting := false
var speed := 120
var direction_x := 0.0
var direction_y := 0.0
var facing_right := true
var has_diamond := false
var has_gun := false
var can_shoot := true
var vulnerable := true
var max_jumps := 2
var jumps_left := max_jumps
var can_regenerate := false 
@onready var dead := false
@onready var entered = false

signal shoot(pos: Vector2, direction: bool)

func _ready():
	if Global.spawn_position != Vector2.ZERO:
		global_position = Global.spawn_position
		Global.spawn_position = Vector2.ZERO 
		$AnimatedSprite2D.material.set_shader_parameter("amount", 1.0)
		start_portal_effect(false)
	if Global.last_checkpoint_pos != Vector2.ZERO:
		global_position = Global.last_checkpoint_pos
	
	
	

		
func _process(delta: float) -> void:
	if is_teleporting:
		velocity = Vector2.ZERO
		move_and_slide()
		return 
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -150
			jumps_left = max_jumps - 1
		elif jumps_left > 0:
			velocity.y = -150
			jumps_left -= 1
	if Input.is_action_pressed("Sprint") and stamina > 0 and can_sprint:
		speed = 150
		stamina -= stamina_drain * delta
		if stamina <= 0:
			stamina = 0
			can_sprint = false
			speed = 120
	else:
		speed = 120
		if stamina < max_stamina:
			stamina += stamina_regen * delta
		if stamina >= 20:
			can_sprint = true

	get_input()
	velocity.x = direction_x * speed 
	move_and_slide()
	gravity()
	get_animation()
	get_facing_direction()

	


func get_input():
	direction_x = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -230
		
		

		
	if Input.is_action_just_pressed("shoot") and can_shoot and has_gun:
		shoot.emit(global_position, facing_right)
		can_shoot = false
		$Timers/CooldownTimer.start()
		$Timers/FireTimer.start()
		$Fire.get_child(facing_right).show()
		
	if Input.is_action_just_pressed("Sprint") and is_on_floor():
		speed = 150
	if Input.is_action_just_released("Sprint"):
		speed = 120
	
		
func gravity():
	velocity.y += 5
	
	
func get_animation():
	var animation = 'idle'
	if not is_on_floor():
		animation = 'jump'
	elif direction_x != 0:
		animation = 'walk'
	if has_gun:
		animation += "_gun"
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.flip_h = not facing_right
	
func get_facing_direction():
	if direction_x != 0:
		facing_right = direction_x >= 0
		
		
	
func get_damage(amount):
	if vulnerable:
		health -= amount
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
	# Resetujemy HP do pełna przy odrodzeniu
	health = 100 
	
	if Global.last_checkpoint_pos != Vector2.ZERO:
		# Używamy set_deferred dla global_position, 
		# bo zmiana pozycji wewnątrz fizyki (collision) bez tego czasem wywala błędy
		set_deferred("global_position", Global.last_checkpoint_pos)
		
		# Zerujemy prędkość, żeby gracz nie "wyleciał" z checkpointu z pędem
		velocity = Vector2.ZERO
		
		# Opcjonalnie: jeśli masz animacje, możesz tu wymusić "idle"
		# $AnimatedSprite2D.play("idle")
		
		print("Odrodzenie na checkpoincie: ", Global.last_checkpoint_pos)
	else:
		# Jeśli nie było checkpointu, restartujemy poziom
		get_tree().reload_current_scene()
	
	if Global.last_checkpoint_pos != Vector2.ZERO:
		# Używamy set_deferred, żeby uniknąć błędów z fizyką przy teleportacji
		set_deferred("global_position", Global.last_checkpoint_pos)
		velocity = Vector2.ZERO
		print("Odrodzenie na checkpoincie")
	
		
		

func _on_cooldown_timer_timeout() -> void:
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
		print("Zregenerowano! Obecne HP: ", health)
		if health >= 100:
			$Timers/GainHealth.stop()
