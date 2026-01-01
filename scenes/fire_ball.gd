extends Area2D

var direction := 1
var speed := 150
var vignette_tween: Tween

func _ready() -> void:
	$AnimatedSprite2D.flip_h = direction > 0

func launch(dir: int):
	direction = dir
	$AnimatedSprite2D.flip_h = (direction < 0)



func _process(delta: float) -> void:
	position.x += speed * direction * delta

func animate_vignette(vignette: ColorRect):
	var mat = vignette.material
	
	# Jeśli stary Tween jeszcze działa, natychmiast go zatrzymaj
	if vignette_tween and vignette_tween.is_running():
		vignette_tween.kill()
	
	vignette_tween = create_tween()
	
	# Ustawienie stanu początkowego (natychmiastowe)
	mat.set_shader_parameter("vignette_color", Color(0.7, 0, 0, 1.0))
	mat.set_shader_parameter("outer_radius", 1.5)
	
	# Płynny powrót
	vignette_tween.parallel().tween_property(mat, "shader_parameter/vignette_color", Color(0, 0, 0, 1.0), 0.5)
	vignette_tween.parallel().tween_property(mat, "shader_parameter/outer_radius", 1.2, 0.5)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("get_damage"):
			body.get_damage(50) # To wywoła animację wewnątrz skryptu gracza
		queue_free()
	else:
		queue_free()
	
