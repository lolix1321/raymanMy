extends Line2D

func _ready():
	# 1. KOLOR: Ekstremalnie jasny (Wypalający oczy)
	default_color = Color(4.0, 4.0, 10.0) 
	
	# 2. GRUBOŚĆ: Zwiększamy, żeby był potężniejszy
	width = 4.0 # Wcześniej było domyślnie 2.0 lub 3.0
	
	# Animacja znikania (bez zmian)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4) # Wydłużyłem też czas do 0.4s, żeby był dłużej widoczny
	tween.tween_callback(queue_free)

	create_zigzag()

func create_zigzag():
	clear_points()
	
	# Startujemy w punkcie spawnu (góra ekranu)
	var start_pos = Vector2(0, 0) 
	
	# --- TU SĄ GŁÓWNE ZMIANY ---
	# X (-200, 200): Piorun może uderzyć trochę w lewo lub w prawo
	# Y (600, 900): Piorun leci MOCNO w dół (długość np. na cały ekran)
	var end_pos = Vector2(randf_range(-200, 200), randf_range(600, 900))
	
	# Zwiększamy liczbę segmentów, żeby długi piorun nie był prostą kreską
	var segments = 15 
	
	add_point(start_pos)
	
	for i in range(1, segments):
		var t = float(i) / segments
		var base_point = start_pos.lerp(end_pos, t)
		
		# Zwiększyłem też "poszarpanie" (jaggedness) z 15 na 30, 
		# żeby piorun był bardziej dziki
		var jaggedness = randf_range(-30, 30)
		var offset = Vector2(jaggedness, jaggedness)
		
		add_point(base_point + offset)
	
	add_point(end_pos)
