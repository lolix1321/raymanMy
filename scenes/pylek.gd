extends ColorRect

func _process(_delta):
	# Pobieramy pozycję kamery z viewportu
	var camera_pos = get_viewport().get_camera_2d().get_screen_center_position()
	
	# Pobieramy materiał (shader) tego obiektu
	var mat = material as ShaderMaterial
	
	if mat:
		# Przesyłamy pozycję do shadera
		# Mnożymy przez małą liczbę (np. 0.05), żeby dopasować skalę ruchu do pikseli
		mat.set_shader_parameter("camera_offset", camera_pos * 0.02)
