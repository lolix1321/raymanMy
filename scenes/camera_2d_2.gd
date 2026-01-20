extends Camera2D

# --- KONFIGURACJA ---
@export var target: CharacterBody2D

@export_category("Poziom (X) - Dead Zone & Akceleracja")
@export var dead_zone_x: float = 40.0      # NOWE: Strefa luzu. Dopóki w niej jesteś, kamera nie zmienia strony.
@export var look_ahead_dist: float = 100.0
@export var reaction_velocity_threshold: float = 60.0 

# Ustawienia rozpędzania się kamery:
@export var min_shift_speed: float = 0.5   
@export var max_shift_speed: float = 4.0   
@export var acceleration_time: float = 0.2

@export_category("Pion (Y)")
@export var look_up_offset: float = -30.0   
@export var catch_up_speed_y: float = 5.0   
@export var fall_threshold: float = 100.0   

# --- ZMIENNE WEWNĘTRZNE ---
var _box_center_x: float = 0.0          # Środek "pudełka" dead zone
var _target_look_ahead: float = 0.0
var _current_look_ahead: float = 0.0
var _target_y: float = 0.0

var _speed_factor: float = 0.0 

func _ready() -> void:
	top_level = true
	position_smoothing_enabled = false 
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	
	if target:
		_box_center_x = target.global_position.x # Ustawiamy środek na start
		_target_y = target.global_position.y + look_up_offset
		global_position = target.global_position + Vector2(0, look_up_offset)
		if target.has_method("get_facing_direction"):
			var facing = 1.0 if target.facing_right else -1.0
			_target_look_ahead = facing * look_ahead_dist
			_current_look_ahead = _target_look_ahead
			_speed_factor = 1.0 

func _physics_process(delta: float) -> void:
	if not target:
		return

	# =========================================
	# 1. OBSŁUGA DEAD ZONE (PUDEŁKA)
	# =========================================
	var dist_from_box = target.global_position.x - _box_center_x
	var is_pushing = false
	
	# Sprawdzamy, czy gracz wyszedł poza strefę luzu
	if abs(dist_from_box) > dead_zone_x:
		var push = dist_from_box - (sign(dist_from_box) * dead_zone_x)
		_box_center_x += push
		is_pushing = true # Gracz pcha krawędź ekranu
	
	# =========================================
	# 2. LOGIKA LOOK AHEAD (AKTYWUJE SIĘ TYLKO PRZY PCHANIU)
	# =========================================
	
	# Zmieniamy cel kamery TYLKO gdy:
	# A. Gracz faktycznie pcha krawędź dead zone (is_pushing)
	# B. Gracz ma odpowiednią prędkość (nie stoi w miejscu)
	if is_pushing and abs(target.velocity.x) > reaction_velocity_threshold:
		var current_facing = sign(target.velocity.x)
		var new_target = current_facing * look_ahead_dist
		
		if _target_look_ahead != new_target:
			_target_look_ahead = new_target
			# Resetujemy rozpęd -> Startujemy powoli w nową stronę
			_speed_factor = 0.0 
	
	# =========================================
	# 3. ROZPĘDZANIE I RUCH
	# =========================================

	# Obliczamy czynnik prędkości (0.0 -> 1.0)
	if _speed_factor < 1.0:
		_speed_factor += delta / acceleration_time
	else:
		_speed_factor = 1.0
		
	# Mieszamy prędkości (Ease-In)
	var current_shift_speed = lerp(min_shift_speed, max_shift_speed, _speed_factor * _speed_factor)
	
	# Przesuwamy Look Ahead
	_current_look_ahead = lerp(_current_look_ahead, _target_look_ahead, current_shift_speed * delta)
	
	# Finalna pozycja X = Środek Pudełka + Wychylenie
	global_position.x = _box_center_x + _current_look_ahead

	# =========================================
	# 4. OŚ Y
	# =========================================
	if target.is_on_floor():
		_target_y = target.global_position.y + look_up_offset
	elif target.global_position.y > _target_y + fall_threshold:
		_target_y = target.global_position.y + look_up_offset - fall_threshold

	var smooth_y = lerp(global_position.y, _target_y, catch_up_speed_y * delta)
	global_position.y = smooth_y
