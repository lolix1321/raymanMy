extends Camera2D

# --- KONFIGURACJA ---
@export var target: CharacterBody2D

@export_category("Poziom (X) - Dead Zone & Akceleracja")
@export var dead_zone_x: float = 40.0        
@export var look_ahead_dist: float = 100.0
@export var reaction_velocity_threshold: float = 60.0 

# Ustawienia rozpędzania się celownika (Look Ahead):
@export var min_shift_speed: float = 0.5    
@export var max_shift_speed: float = 4.0    
@export var acceleration_time: float = 0.2

@export_category("Pion (Y)")
@export var look_up_offset: float = -30.0    
@export var catch_up_speed_y: float = 5.0    
@export var fall_threshold: float = 100.0    

# --- ZMIENNE WEWNĘTRZNE ---
var _box_center_x: float = 0.0          
var _target_look_ahead: float = 0.0
var _current_look_ahead: float = 0.0
var _target_y: float = 0.0

# Te zmienne przechowują cel obliczony w fizyce, do którego dążymy w process
var _sync_target_x: float = 0.0
var _sync_target_y: float = 0.0

var _speed_factor: float = 0.0 

func _ready() -> void:
	# ==============================================================================
	# KLUCZOWA POPRAWKA:
	# Wyłączamy interpolację silnika dla TEGO węzła (kamery).
	# Dzięki temu Gracz jest interpolowany (przez ustawienia projektu),
	# a Kamera jest sterowana ręcznie przez nas w _process (bez blokowania).
	# ==============================================================================
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	
	top_level = true
	position_smoothing_enabled = false 
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	
	if target:
		_box_center_x = target.global_position.x 
		_target_y = target.global_position.y + look_up_offset
		global_position = target.global_position + Vector2(0, look_up_offset)
		
		if target.has_method("get_facing_direction"):
			var facing = 1.0 if target.facing_right else -1.0
			_target_look_ahead = facing * look_ahead_dist
			_current_look_ahead = _target_look_ahead
			_speed_factor = 1.0 
		
		# Inicjalizacja celów synchronizacji
		_sync_target_x = global_position.x
		_sync_target_y = global_position.y

# 1. MYŚLENIE (FIZYKA - 60 razy na sekundę)
# Tutaj obliczamy logiczną pozycję kamery, ale jej NIE przesuwamy.
func _physics_process(delta: float) -> void:
	if not target:
		return

	# --- Dead Zone Logic ---
	# Używamy global_position targetu (który w fizyce jest dokładny)
	var dist_from_box = target.global_position.x - _box_center_x
	var is_pushing = false
	
	if abs(dist_from_box) > dead_zone_x:
		var push = dist_from_box - (sign(dist_from_box) * dead_zone_x)
		_box_center_x += push
		is_pushing = true 
	
	# --- Look Ahead Logic ---
	if is_pushing and abs(target.velocity.x) > reaction_velocity_threshold:
		var current_facing = sign(target.velocity.x)
		var new_target = current_facing * look_ahead_dist
		
		if _target_look_ahead != new_target:
			_target_look_ahead = new_target
			_speed_factor = 0.0 
	
	# --- Rozpędzanie Look Ahead ---
	if _speed_factor < 1.0:
		_speed_factor += delta / acceleration_time
	else:
		_speed_factor = 1.0
		
	var current_shift_speed = lerp(min_shift_speed, max_shift_speed, _speed_factor * _speed_factor)
	
	# Wygładzanie samego celownika (Look Ahead) w fizyce
	var t_x = 1.0 - exp(-current_shift_speed * delta)
	_current_look_ahead = lerp(_current_look_ahead, _target_look_ahead, t_x)
	
	# ZAPISUJEMY CEL DLA PROCESU GRAFICZNEGO
	# To jest pozycja, gdzie kamera "powinna być" według zasad gry.
	_sync_target_x = _box_center_x + _current_look_ahead

	# --- Logic Y ---
	if target.is_on_floor():
		_target_y = target.global_position.y + look_up_offset
	elif target.global_position.y > _target_y + fall_threshold:
		_target_y = target.global_position.y + look_up_offset - fall_threshold
		
	_sync_target_y = _target_y

# 2. RYSOWANIE (GRAFIKA - 144/165/60 razy na sekundę)
# Tutaj przesuwamy kamerę w każdym odświeżeniu ekranu.
func _process(delta: float) -> void:
	# smooth_power: Im wyższa wartość, tym kamera sztywniej trzyma się celu.
	# 25.0 to dobry balans między brakiem laga a brakiem drgań.dw
	var smooth_power = 25.0 
	
	# Obliczamy idealny "dociąg" niezależny od klatkażu
	var t = 1.0 - exp(-smooth_power * delta)
	
	# Płynny ruch X
	global_position.x = lerp(global_position.x, _sync_target_x, t)
	
	# Płynny ruch Y (z własną prędkością)
	var t_y = 1.0 - exp(-catch_up_speed_y * delta)
	global_position.y = lerp(global_position.y, _sync_target_y, t_y)
