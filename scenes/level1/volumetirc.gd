extends ColorRect

@export var sun_object: Node2D 

func _process(_delta):
	var cam = get_viewport().get_camera_2d()
	if cam:
		# 1. Dopasuj rozmiar prostokąta do zooma kamery (żeby zawsze wypełniał ekran)
		size = get_viewport_rect().size / cam.zoom
		
		# 2. Ustaw pozycję prostokąta idealnie na środku widoku kamery
		# (Odejmujemy połowę rozmiaru, bo pozycja to lewy górny róg)
		global_position = cam.get_screen_center_position() - size / 2

	# --- Tutaj stara część kodu do Słońca ---
	if sun_object:
		var sun_screen_pos = sun_object.get_global_transform_with_canvas().origin
		var viewport_size = get_viewport_rect().size
		var sun_uv = sun_screen_pos / viewport_size
		material.set_shader_parameter("light_position", sun_uv)
