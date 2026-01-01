extends Area2D

var direction := 1
var speed := 150

func _ready() -> void:
	$AnimatedSprite2D.flip_h = direction > 0

func launch(dir: int):
	direction = dir
	$AnimatedSprite2D.flip_h = (direction < 0)



func _process(delta: float) -> void:
	position.x += speed * direction * delta

func animate_vignette(vignette: ColorRect):
	var mat = vignette.material
	var tween = create_tween()
	
	# 1. Natychmiast ustaw kolor na czerwony i zacieśnij winietę
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0)) # Ciemna czerwień
	mat.set_shader_parameter("outer_radius", 1.5) # Mocne przyciemnienie
	
	# 2. Płynnie wróć do normalnego wyglądu (czarny i szeroki promień)
	tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var vignette = get_tree().get_first_node_in_group("Vignette")
		if vignette:
			# Zamiast odpalać animację tutaj, wywołaj funkcję w graczu lub kontrolerze UI
			animate_vignette(vignette)
		
		if body.has_method("get_damage"):
			body.get_damage(50)
		
		# UKRYWAMY pocisk zamiast go od razu usuwać, 
		# aby Tween mógł dokończyć działanie
		set_deferred("monitoring", false)
		visible = false
		
		# Usuwamy pocisk dopiero po zakończeniu animacji (np. po 0.6s)
		get_tree().create_timer(0.6).timeout.connect(queue_free)
	else:
		queue_free()
	
