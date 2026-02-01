extends Node2D

# --- CZĘŚĆ METEORYTÓW ---
@export var meteor_scene: PackedScene 

# --- CZĘŚĆ BŁYSKAWIC ---
@export var lightning_bolt_scene: PackedScene 

@onready var lightning_timer = $LightningTimer
@onready var lightning_anim = $LightningAnim
# Upewnij się, że ta ścieżka do LightningFlash jest poprawna w Twoim drzewie!
@onready var lightning_flash_rect = $ParallaxBackground/Clouds2/LightningFlash 

func _ready():
	# 1. Konfiguracja meteorytów (zakładam, że masz Timer o nazwie MeteorTimer podpięty w edytorze)
	# Jeśli nie masz podpiętego w edytorze, odkomentuj linię poniżej:
	# $MeteorTimer.timeout.connect(_on_meteor_timer_timeout)
	$Player.get_node("CameraTarget/Level1Camera").enabled = false
	# 2. Konfiguracja błyskawic
	if lightning_flash_rect:
		lightning_flash_rect.modulate = Color(0.8, 0.9, 1.0) * 1.5
		lightning_flash_rect.modulate.a = 0.0 
	
	# Podłączamy timer błyskawic kodem

	start_random_lightning_timer()


# --- PRZYWRÓCONA FUNKCJA METEORYTÓW ---
func _on_meteor_timer_timeout():
	if meteor_scene:
		var meteor = meteor_scene.instantiate()
		
		# Ustawienie losowej pozycji startowej
		# Zmieniłem zakres X na trochę szerszy, dostosuj wg uznania
		meteor.position = Vector2(randf_range(-200, 1000), -50)
		
		# Dodajemy meteoryt do tła
		# Upewnij się, że masz węzeł 'Background' w 'ParallaxBackground'
		if $ParallaxBackground/Background:
			$ParallaxBackground/Background.add_child(meteor)
		else:
			# Fallback, gdyby ścieżka była inna - dodajemy po prostu do sceny
			add_child(meteor)


# --- FUNKCJE BŁYSKAWIC ---
func start_random_lightning_timer():
	var random_time = randf_range(3.0, 10.0)
	lightning_timer.wait_time = random_time
	lightning_timer.start()

func _on_lightning_timer_timeout():
	# 1. FLASH EKRANU
	if lightning_anim.has_animation("flash"):
		lightning_anim.play("flash")
	
	# 2. STWORZENIE PIORUNA
	spawn_lightning_bolt()
	
	# 3. Opcjonalnie: EFEKT TRZĘSIENIA KAMERĄ (jeśli dodasz ten skrypt do kamery)
	# if has_node("Player/Camera2D"):
	# 	$Player/Camera2D.apply_shake(5.0)
	
	start_random_lightning_timer()

func spawn_lightning_bolt():
	if lightning_bolt_scene:
		var bolt = lightning_bolt_scene.instantiate()
		
		# Losowa pozycja pioruna
		var random_x = randf_range(0, 1000) 
		var start_y = -100 
		
		bolt.position = Vector2(random_x, start_y)
		
		# Dodajemy piorun do warstwy chmur (dopasuj ścieżkę jeśli inna)
		if $ParallaxBackground/Clouds_back:
			$ParallaxBackground/Clouds_back.add_child(bolt)
		else:
			add_child(bolt)
