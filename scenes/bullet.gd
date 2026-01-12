extends Area2D

var direction := 1
@export var speed := 300
@export var blood_scene: PackedScene 
@export var shake_amount := 0.2 # Siła traumy dodawana do kamery (0.0 - 1.0)

func _ready():
	shake_amount = 0.2
	# Ustawienie kierunku sprite'a na starcie
	$Sprite2D.flip_h = direction < 0

func _process(delta):
	position.x += speed * direction * delta

# To jest jedyna funkcja obsługująca wejście w obszar
func _on_area_entered(area: Area2D) -> void:
	# Sprawdzamy grupę - trzęsienie i krew pojawią się TYLKO dla przeciwników
	if area.is_in_group("enemies"):
		var c = Color.RED
		if "blood_color" in area:
			c = area.blood_color
			
		spawn_blood(c)
		apply_screen_shake() # Wywołujemy tylko tutaj
		queue_free() # Pocisk znika po trafieniu w przeciwnika

func spawn_blood(color_to_apply: Color):
	if blood_scene:
		var blood = blood_scene.instantiate()
		get_tree().current_scene.add_child(blood)
		blood.global_position = global_position
		blood.modulate = color_to_apply
		
		if direction < 0:
			blood.rotation_degrees = 180 
		else:
			blood.rotation_degrees = 0
			
			
func apply_screen_shake():
	var camera = get_viewport().get_camera_2d()
	if camera:
		if camera.has_method("add_trauma"):
			camera.add_trauma(shake_amount)
			print("SHAKE POSZEDŁ") # Sprawdź w konsoli czy to wypisuje
		else:
			print("KAMERA NIE MA METODY")
	else:
		print("NIE ZNALAZŁO KAMERY")

func bullet():
	pass
	
func _on_body_entered(body: Node2D) -> void:
	call_deferred("queue_free")
	queue_free()
