extends Area2D
var max_health:int = 5
var health := max_health
var speed := 30
var direction_x := 1
var is_shooting := false
var facing_right := true
@export var fire_ball: PackedScene
@onready var timer = $Timer
@onready var marker = $Marker2D
@onready var sprite = $AnimatedSprite2D
const fireball_scene: PackedScene = preload("res://scenes/fire_ball.tscn")

@onready var player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	update_health()
	if not is_shooting:
		$AnimatedSprite2D.play("default") 
	
	if direction_x == 1:
		marker.rotation = 0
	else:
		marker.rotation = PI 
		
	check_death()

func check_death():
	if health <= 0:
		queue_free()


func change_direction():
	direction_x *= -1 
	sprite.flip_h = not sprite.flip_h
	marker.position.x = abs(marker.position.x) * direction_x

func _on_walneicie_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		change_direction()

func _on_right_cliff_body_exited(body: Node2D) -> void:
	# Dodajemy sprawdzenie, czy body to nie null (bezpieczeństwo)
	if body and not body.is_in_group("Player"):
		change_direction()

func _on_left_cliff_body_exited(body: Node2D) -> void:
	if body and not body.is_in_group("Player"):
		change_direction()

func _on_timer_timeout() -> void:
	shoot()



		
func shoot():

	if fire_ball:
		is_shooting = true
		$AnimatedSprite2D.play("shoot")
		
		var bullet = fire_ball.instantiate()
		get_tree().root.add_child(bullet)
		
		bullet.global_position = marker.global_position
		
		var _look_direction = -1 if $AnimatedSprite2D.flip_h else 1
		bullet.launch(direction_x)
		
		if direction_x == 1:
			bullet.direction = 1
		else:
			bullet.direction = -1




func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	var tween = create_tween() 
	# Naprawiłem tweena - teraz poprawnie mignie od 1.0 do 0.0
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.1)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "shoot":
		is_shooting = false
		
		

func update_health():
	var healthbar = $HealthBar
	healthbar.max_value = max_health
	healthbar.value = health
	healthbar.visible = health < max_health
